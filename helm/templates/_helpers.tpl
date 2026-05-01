{{/*
Expand the name of the chart.
*/}}
{{- define "streamvault.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
If the release name already contains the chart name, use the release name alone.
*/}}
{{- define "streamvault.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart label value (name-version).
*/}}
{{- define "streamvault.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to every resource.
*/}}
{{- define "streamvault.labels" -}}
helm.sh/chart: {{ include "streamvault.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ include "streamvault.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Component-scoped selector labels.
Usage: {{ include "streamvault.componentSelectorLabels" (list . "postgres") }}
*/}}
{{- define "streamvault.componentSelectorLabels" -}}
{{- $root := index . 0 -}}
{{- $component := index . 1 -}}
app.kubernetes.io/name: {{ include "streamvault.name" $root }}
app.kubernetes.io/instance: {{ $root.Release.Name }}
app.kubernetes.io/component: {{ $component }}
{{- end }}

{{/*
Name of the shared secret containing all credentials.
*/}}
{{- define "streamvault.secretName" -}}
{{- printf "%s-secrets" (include "streamvault.fullname" .) }}
{{- end }}
