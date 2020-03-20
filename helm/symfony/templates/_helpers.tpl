{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/* Helm required labels */}}
{{- define "labels" -}}
heritage: {{ .Release.Service }}
release: {{ .Release.Name }}
chart: {{ .Chart.Name }}
app: "{{ template "name" . }}"
{{- end -}}

{{/* matchLabels */}}
{{- define "matchLabels" -}}
release: {{ .Release.Name }}
app: "{{ template "name" . }}"
{{- end -}}

{{- define "php" -}}
  {{- printf "%s-php" (include "fullname" .) -}}
{{- end -}}

{{- define "fpm" -}}
  {{- printf "%s-fpm" (include "fullname" .) -}}
{{- end -}}

{{- define "supervisor" -}}
  {{- printf "%s-supervisor" (include "fullname" .) -}}
{{- end -}}

{{- define "nginx" -}}
  {{- printf "%s-nginx" (include "fullname" .) -}}
{{- end -}}

{{- define "databaseDsn" -}}
  {{- if .Values.mysql.internal }}
    {{- printf "mysql://%s:%s@%s/%s?serverVersion=5.7" (.Values.mysql.mysqlUser | quote) (.Values.mysql.mysqlPassword | quote) (include "mysql.fullname" .) (.Values.mysql.mysqlDatabase | quote) -}}
  {{- else }}
    {{- .Values.mysql.externalDsn -}}
  {{- end }}
{{- end -}}

{{- define "messengerTransportDsn" -}}
  {{- if .Values.mysql.internal }}
    {{- printf "amqp://%s:%s@%s:%d/%s" (.Values.rabbitmq.rabbitmq.username | quote) (.Values.rabbitmq.rabbitmq.password | quote) (.Values.rabbitmq.service.port | quote) (include "rabbitmq.fullname" .) "%2f" -}}
  {{- else }}
    {{- .Values.rabbitmq.externalDsn -}}
  {{- end }}
{{- end -}}