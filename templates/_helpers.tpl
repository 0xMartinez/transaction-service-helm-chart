
{{- define "transaction-service.fullname" -}}
{{ .Release.Name }}
{{- end }}


{{/*
Zwraca nazwę aplikacji (Chart name)
*/}}
{{- define "transaction-service.name" -}}
{{ .Chart.Name }}
{{- end }}
