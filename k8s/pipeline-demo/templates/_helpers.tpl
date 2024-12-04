{{ define "pipelineDemo.commonLabels" -}}
app.kubernetes.io/name: {{ .Global.Chart.Name }}
app.kubernetes.io/managed-by: {{ .Global.Release.Service }}
app.kubernetes.io/instance: {{ .Global.Release.Name }}
app.kubernetes.io/part-of: {{ .PartOf | quote }}
app.kubernetes.io/component: {{ .Component | quote }}
{{- end }}

{{ define "pipelineDemo.commonMetadata" -}}
namespace: {{ .Global.Release.Namespace }}
labels:
{{ include "pipelineDemo.commonLabels" . | indent 2 }}
{{- end }}

{{ define "pipelineDemo.computedS3Endpoint" -}}
{{ if .Values.minioAlreadyAvailable }}{{ .Values.s3Endpoint }}{{ else }}{{ printf "%s-minio-svc.%s:9000" .Release.Name .Release.Namespace }}{{ end }}
{{- end }}