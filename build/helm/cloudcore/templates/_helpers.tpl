{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cloudcore.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cloudcore.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Generate certificates for kubeedge cloudstream server
*/}}
{{- define "cloudcore.gen-certs" -}}
{{- $altNames := list ( printf "%s.%s" (include "cloudcore.name" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "cloudcore.name" .) .Release.Namespace ) -}}
{{- $ca := genCA "cloudcore-ca" 365 -}}
{{- $cert := genSignedCert ( include "cloudcore.name" . ) nil $altNames 365 $ca -}}
streamCA.crt: {{ $ca.Cert | b64enc }}
stream.crt: {{ $cert.Cert | b64enc }}
stream.key: {{ $cert.Key | b64enc }}
{{- end -}}

{{/*
Generate certificates for kubeedge cloudhub server
*/}}
{{- define "cloudcore.gen-cloudhub-certs" -}}
{{- $ips := .Values.cloudCore.modules.cloudHub.advertiseAddress }}
{{- $cn := printf "KubeEdge" }}
{{- $ca := genCA "KubeEdge" 36500 -}}
{{- $cert := genSignedCert $cn $ips nil 36500 $ca -}}
rootCA.crt: {{ $ca.Cert | b64enc }}
rootCA.key: {{ $ca.Key | b64enc }}
server.crt: {{ $cert.Cert | b64enc }}
server.key: {{ $cert.Key | b64enc }}
{{- end -}}
