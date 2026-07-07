# Build context: CollabOn_WebApp/
# Usage: docker build --build-arg VITE_API_BASE_URL=https://api.example.com -t collabon-frontend:latest .

# ---
# Stage 1 — Build
# ---
FROM node:20-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm ci --ignore-scripts

ARG VITE_API_BASE_URL
ARG VITE_APP_ENV=production
ARG VITE_ENABLE_MOCK_DATA=false

ENV VITE_API_BASE_URL=$VITE_API_BASE_URL
ENV VITE_APP_ENV=$VITE_APP_ENV
ENV VITE_ENABLE_MOCK_DATA=$VITE_ENABLE_MOCK_DATA

COPY . .

# Two source files import from "components/services/" but the actual files live in "services/".
RUN mkdir -p src/components/services && \
    ln -sf /app/src/services/branchService.ts src/components/services/branchService.ts && \
    ln -sf /app/src/services/dashboardService.ts src/components/services/dashboardService.ts

# Patch source-code bugs at build time without modifying committed files:
#   - SuperAdminDashboard.tsx: KPI_DATA → KPI_WITH_ICONS  (not yet fixed in source)
#   - CRM.tsx: missing exports SEED_ALL_PLANS / SEED_ALL_STATUSES / SEED_ALL_STRUCTURES / PLAN_STYLE / STATUS_STYLE  (not yet fixed in source)
#   Fixed in source as of BN/refactor/mockdata-cleanup — patches removed:
#   - GroupsContext.tsx: re-exports now in source
#   - AssignShift.tsx: typo fixed in source
RUN echo "Y29uc3QgZnMgPSByZXF1aXJlKCdmcycpOwoKZnVuY3Rpb24gcGF0Y2gocGF0aCwgZnJvbSwgdG8sIGxhYmVsKSB7CiAgbGV0IHNyYyA9IGZzLnJlYWRGaWxlU3luYyhwYXRoLCAndXRmOCcpOwogIGlmICghc3JjLmluY2x1ZGVzKGZyb20pKSB7CiAgICBjb25zb2xlLmVycm9yKCdQQVRDSCBNSVNTIFsnICsgbGFiZWwgKyAnXTogcGF0dGVybiBub3QgZm91bmQgaW4gJyArIHBhdGgpOwogICAgcmV0dXJuOwogIH0KICBmcy53cml0ZUZpbGVTeW5jKHBhdGgsIHNyYy5yZXBsYWNlKGZyb20sIHRvKSk7CiAgY29uc29sZS5sb2coJ1BhdGNoZWQgJyArIGxhYmVsKTsKfQoKLy8gMS4gU3VwZXJBZG1pbkRhc2hib2FyZC50c3g6IEtQSV9EQVRBIOKGkiBLUElfV0lUSF9JQ09OUyAoc3RhbGUgdmFyaWFibGUgbmFtZSkKcGF0Y2goCiAgJ3NyYy9wYWdlcy9zdXBlci1hZG1pbi9kYXNoYm9hcmQvU3VwZXJBZG1pbkRhc2hib2FyZC50c3gnLAogICcuLi5LUElfREFUQS5tYXAoJywKICAnLi4uS1BJX1dJVEhfSUNPTlMubWFwKCcsCiAgJ1N1cGVyQWRtaW5EYXNoYm9hcmQgS1BJX0RBVEEnCik7CgovLyAyLiBDUk0udHN4OiBTRUVEX0FMTF9QTEFOUyAvIFNFRURfQUxMX1NUQVRVU0VTIC8gU0VFRF9BTExfU1RSVUNUVVJFUyBhcmUgbm90Ci8vICAgIGV4cG9ydGVkIGZyb20gbW9ja0RhdGE7IFBMQU5fU1RZTEUgYW5kIFNUQVRVU19TVFlMRSBhcmUgdW5kZWZpbmVkLgovLyAgICBGaXg6IHJlbW92ZSB0aGVtIGZyb20gdGhlIGltcG9ydCBhbmQgZGVmaW5lIHRoZW0gbG9jYWxseS4KcGF0Y2goCiAgJ3NyYy9wYWdlcy9zdXBlci1hZG1pbi9jcm0vQ1JNLnRzeCcsCiAgJ2ltcG9ydCB7IFNFRURfTEVBRFMsIFNFRURfQ1JNX01FVFJJQ1MsIFNFRURfQUxMX1NUUlVDVFVSRVMsIFNFRURfQUxMX1BMQU5TLCBTRUVEX0FMTF9TVEFUVVNFUywgU0VFRF9MRUFEX1NPVVJDRVMsIFNFRURfRU5HQUdFTUVOVF9NT0RFTFMsIFNFRURfQUNUSU9OX1RZUEVTIH0gZnJvbSAiLi4vLi4vLi4vdHlwZXMvbW9ja0RhdGEiOycsCiAgWwogICAgJ2ltcG9ydCB7IFNFRURfTEVBRFMsIFNFRURfQ1JNX01FVFJJQ1MsIFNFRURfTEVBRF9TT1VSQ0VTLCBTRUVEX0VOR0FHRU1FTlRfTU9ERUxTLCBTRUVEX0FDVElPTl9UWVBFUyB9IGZyb20gIi4uLy4uLy4uL3R5cGVzL21vY2tEYXRhIjsnLAogICAgJ2NvbnN0IFNFRURfQUxMX1BMQU5TID0gWyJTdGFydGVyIiwgIkdyb3d0aCIsICJFbnRlcnByaXNlIl07JywKICAgICdjb25zdCBTRUVEX0FMTF9TVEFUVVNFUyA9IFsiTmV3IiwgIkZvbGxvdyBVcCIsICJIb2xkIiwgIkxvc3QiLCAiQ29udmVydGVkIC0gVHJhaWwgVmVyc2lvbiIsICJDb252ZXJ0ZWQgLSBQYWlkIFZlcnNpb24iXTsnLAogICAgJ2NvbnN0IFNFRURfQUxMX1NUUlVDVFVSRVMgPSBbIlNpbmdsZSIsICJHcm91cCJdOycsCiAgICAnY29uc3QgUExBTl9TVFlMRSA9IHsgIlN0YXJ0ZXIiOiAiYmctYmx1ZS01MCB0ZXh0LWJsdWUtNzAwIiwgIkdyb3d0aCI6ICJiZy1wdXJwbGUtNTAgdGV4dC1wdXJwbGUtNzAwIiwgIkVudGVycHJpc2UiOiAiYmctYW1iZXItNTAgdGV4dC1hbWJlci03MDAiIH07JywKICAgICdjb25zdCBTVEFUVVNfU1RZTEUgPSB7ICJOZXciOiAidGV4dC1ibHVlLTYwMCIsICJGb2xsb3cgVXAiOiAidGV4dC1vcmFuZ2UtNjAwIiwgIkhvbGQiOiAidGV4dC15ZWxsb3ctNjAwIiwgIkxvc3QiOiAidGV4dC1yZWQtNjAwIiwgIkNvbnZlcnRlZCAtIFRyYWlsIFZlcnNpb24iOiAidGV4dC1ncmVlbi02MDAiLCAiQ29udmVydGVkIC0gUGFpZCBWZXJzaW9uIjogInRleHQtZW1lcmFsZC03MDAiIH07JywKICBdLmpvaW4oJ1xuJyksCiAgJ0NSTSBtaXNzaW5nIGV4cG9ydHMgKyBQTEFOX1NUWUxFICsgU1RBVFVTX1NUWUxFJwopOwo=" \
    | base64 -d > /tmp/patch.js && node /tmp/patch.js

RUN npx vite build

# ---
# Stage 2 — Serve
# ---
FROM nginx:1.27-alpine

RUN rm -rf /usr/share/nginx/html/*

COPY --from=build /app/dist /usr/share/nginx/html

RUN printf '%s\n' \
  'server {' \
  '    listen 80;' \
  '    server_name _;' \
  '    root /usr/share/nginx/html;' \
  '    index index.html;' \
  '    location / { try_files $uri $uri/ /index.html; }' \
  '    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|map)$ {' \
  '        expires 1y; add_header Cache-Control "public, immutable"; access_log off;' \
  '    }' \
  '    location = /index.html {' \
  '        add_header Cache-Control "no-cache, no-store, must-revalidate";' \
  '        add_header Pragma "no-cache"; add_header Expires "0";' \
  '    }' \
  '    add_header X-Frame-Options "SAMEORIGIN" always;' \
  '    add_header X-Content-Type-Options "nosniff" always;' \
  '    add_header Referrer-Policy "strict-origin-when-cross-origin" always;' \
  '    location = /health { return 200 "ok\n"; add_header Content-Type text/plain; access_log off; }' \
  '    location ~ /\. { deny all; }' \
  '}' \
  > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
