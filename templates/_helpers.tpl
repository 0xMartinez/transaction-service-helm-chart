{{- define "transaction-service.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Zwraca nazwę aplikacji (Chart name)
*/}}
{{- define "transaction-service.name" -}}
{{ .Chart.Name }}
{{- end }}
