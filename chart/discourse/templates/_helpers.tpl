{{- define "discourse.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "discourse.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "discourse.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- define "discourse.labels" -}}
app.kubernetes.io/name: {{ include "discourse.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}
{{- define "discourse.dbHost" -}}
{{- if eq .Values.database.provider "postgresql" -}}
{{- include "discourse.fullname" . }}-postgresql
{{- else if eq .Values.database.provider "cloudnative-pg" -}}
{{- printf "%s-postgresql-rw" (include "discourse.fullname" .) -}}
{{- else -}}
{{- .Values.database.external.host -}}
{{- end -}}
{{- end -}}
{{- define "discourse.redisHost" -}}
{{- if eq .Values.redis.provider "standalone" -}}
{{- include "discourse.fullname" . }}-redis
{{- else -}}
{{- .Values.redis.external.host -}}
{{- end -}}
{{- end -}}
