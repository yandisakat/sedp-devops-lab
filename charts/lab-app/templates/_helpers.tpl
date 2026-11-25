{{- define "lab-app.name" -}}lab-app{{- end -}}

{{- define "lab-app.labels" -}}
app.kubernetes.io/name: {{ include "lab-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ include "lab-app.version" . | quote }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}

{{- define "lab-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lab-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "lab-app.version" -}}{{ .Values.image.tag | default .Chart.AppVersion }}{{- end -}}

{{/* Pod template shared by the Deployment and the Rollout. */}}
{{- define "lab-app.podTemplate" -}}
metadata:
  labels:
    {{- include "lab-app.selectorLabels" . | nindent 4 }}
  annotations:
    # Changing the config changes this hash, which rolls the pods automatically.
    checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
    {{- with .Values.podAnnotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  terminationGracePeriodSeconds: 20
  containers:
    - name: app
      image: "{{ .Values.image.repository }}:{{ include "lab-app.version" . }}"
      imagePullPolicy: {{ .Values.image.pullPolicy }}
      ports:
        - name: http
          containerPort: 8000
      env:
        - name: APP_VERSION
          value: {{ include "lab-app.version" . | quote }}
      envFrom:
        - configMapRef:
            name: {{ include "lab-app.name" . }}
      resources:
        {{- toYaml .Values.resources | nindent 8 }}
      startupProbe:
        httpGet: { path: /healthz, port: http }
        periodSeconds: 2
        failureThreshold: 30
      livenessProbe:
        httpGet: { path: /healthz, port: http }
        periodSeconds: 10
      readinessProbe:
        httpGet: { path: /readyz, port: http }
        periodSeconds: 3
      lifecycle:
        preStop:
          exec: { command: ["sleep", "5"] }
      securityContext:
        runAsNonRoot: true
        allowPrivilegeEscalation: false
{{- end -}}
