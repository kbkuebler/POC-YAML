for SC in fio-repl1 fio-repl1-encrypted fio-repl2 fio-repl2-encrypted; do
  kubectl apply -f - <<EOF
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: $SC-pvc
  namespace: portworx
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
  storageClassName: $SC
---
apiVersion: v1
kind: Pod
metadata:
  name: $SC
  namespace: portworx
  labels:
    app: fio
spec:
  schedulerName: stork
  containers:
  - name: fio-write
    image: dmonakhov/alpine-fio
    securityContext:
      privileged: true
    volumeMounts:
    - mountPath: /data
      name: test-volume
    - mountPath: /fiocfg
      name: fiocfg
    args:
      - "sleep"
      - "10000"
    imagePullPolicy: IfNotPresent
  restartPolicy: Never
  volumes:
  - name: test-volume
    persistentVolumeClaim:
      claimName: $SC-pvc
  - name: fiocfg
    configMap:
      name: fiocfg
EOF
done
