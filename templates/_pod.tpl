{{- define "proxysql.pod" -}}
metadata:
  annotations:
    checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }} 
{{- with .Values.podAnnotations }}
    {{- toYaml . | nindent 4 }}
{{- end }}
  labels:
    {{- include "proxysql.selectorLabels" . | nindent 4 }}
spec:
  {{- with .Values.imagePullSecrets }}
  imagePullSecrets:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  serviceAccountName: {{ include "proxysql.serviceAccountName" . }}
  securityContext:
    {{- toYaml .Values.podSecurityContext | nindent 4 }}
  containers:
    - name: {{ .Chart.Name }}
      image: "{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
      imagePullPolicy: {{ .Values.image.pullPolicy }}
      securityContext:
        {{- toYaml .Values.securityContext | nindent 8 }}
      command:
        - proxysql
        - "-f"
        - "--idle-threads"
        - "-D"
        - "/var/lib/proxysql"
        - "--reload"
      ports:
        - name: mysql
          containerPort: {{ .Values.proxysql.mysql.port }}
          protocol: TCP
        - name: proxysql
          containerPort: {{ .Values.proxysql.port }}
          protocol: TCP
        {{- if .Values.proxysql.web.enabled }}
        - name: web
          containerPort: {{ .Values.proxysql.web.port }}
          protocol: TCP
        {{- end }}
        {{- if .Values.metrics.enabled }}
        - name: metrics
          containerPort: 6070
          protocol: TCP
        {{- end }}
      livenessProbe:
        tcpSocket:
          port: proxysql
      readinessProbe:
        tcpSocket:
          port: proxysql
      lifecycle:
        preStop:
          exec:
            command: ["/bin/sh", "-c", "/usr/local/bin/wait_queries_to_finish.sh"]
      volumeMounts:
        - name: proxysql-config
          mountPath: /etc/proxysql.cnf
          subPath: proxysql.cnf
          readOnly: true
        - name: proxysql-scripts
          mountPath: /usr/local/bin/wait_queries_to_finish.sh
          subPath: wait_queries_to_finish.sh
          readOnly: true
      {{- if and .Values.proxysql.cluster.enabled .Values.proxysql.cluster.claim.enabled }}
        - name: {{ include "proxysql.fullname" . }}-pv
          mountPath: /var/lib/proxysql
      {{- end }}
      resources:
        {{- toYaml .Values.resources | nindent 8 }}
  terminationGracePeriodSeconds: {{ .Values.terminationGracePeriodSeconds | default 300 }}
  volumes:
    - name: proxysql-config
      configMap:
        name: {{ .Values.proxysql.configmap | default (include "proxysql.fullname" .) }}
    - name: proxysql-scripts
      configMap:
        name: {{ include "proxysql.fullname" . }}-scripts
        items:
        - key: "wait_queries_to_finish.sh"
          path: "wait_queries_to_finish.sh"
          mode: 0777
  {{- with .Values.nodeSelector }}
  nodeSelector:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.affinity }}
  affinity:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.tolerations }}
  tolerations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
