# Helm chart do wdrożenia aplikacji "System do obsługi transakcji płatniczych w Spring Boot"

Helm chart pozwala na uruchomienie aplikacji w klastrze Kubernetes i jest zgodny z wersjami Kybernetes 1.22+

Wszystkie zmienne wymagające jakiejkolwiek edycji zostały zawarte w pliku values.yaml.
W celu zapewnienia wysokiej dostępności alikacja jest uruchamiana w 2 instancjach.

Wdrożona aplikacja pozwala na edytowanie adresu oraz domeny klastra. Przy pierwszym uruchomieniu oraz przy każdorazowej zmianie adresu/domeny należy dodać wpis do pliku etc/hosts lączący nowy hostname z adresem 1.0.0.127 (localhost).
Domyślnie ustawionym adresem jest 
```
hostname: "transaction-service.local"
```
Aplikacja ma wyłączone automatyczne generowanie topików Kafki. 
Aplikacja domyślnie tworzy dwa topiki o nazwach wskazanych w values.yaml i przekazuje je do aplikacji Spring przez zmienne środowiskowe zdefiniowane w deployments.yaml: 
```
predefinedTopics: # configuration for Kafka topics name
  completed:
    name: transakcje-zrealizowane
  expired:
    name: transakcje-przeterminowane
```
Dotatkowo w kontekście topików, została dodana funkcjonalość "expirowania" wiadomości w topikach kafki. Wartości również znajdują się w values.yaml:
```
    extraConfig: |- # message expiration config in miliseconds
      log.retention.ms: 60000
      log.retention.check.interval.ms: 300000
```
Sama Kafka działa w oparciu o architekturę z zookeeperem. Wszystkie niezbędne wartości wymagające nadpisania oryginalnej konfiguracji, zostały nadpisane w pliku values.yaml. 
Ponieważ domyślnie aplikacja posiada wbudowaną baze danych h2, która w domyślnym trybie jest wbudowana w środowisko aplikacji, potrzebne było przestawienie bazy danych w tryb "Server Mode" w celu zdalnego używania bazy danych przez api.
Pozostanie w domyślnym trybie Embedded z wiecej niż jedną repliką aplikacji powodowało, że naprzemiennie w użyciu były 2 odrębne bazy danych.

Poprzez ingress zostały udostępnione endpoint dla wszystkich funkcjonalności (prezentowane wartości, zmienią sie po edycji hostname):
* api do zarządzania transakcjami poprzez swagger: [http://transaction-service.local/swagger-ui/index.html]
* api do zarządzania płatnościami poprzez soap: [http://transaction-service.local/ws]
* actuator (dodany na etapie developmentu helm chartu, użyty do testów, w celu weryfikacji czy aplikacja "wstała" poprawnie): [http://transaction-service.local/actuator/health]
* plik openapi.yaml zawierający definicję wystawionego REST API: [http://transaction-service.local/openapi/openapi.yaml]

Instrukcja uruchomienia
-------------------------------
* wystartuj kontener kubernetes
* włącz tunnelowania (przykład)
```
minikube tunnel
```
* dodaj hostname razem z adresem 1.0.0.127 (domyślnie: transaction-service.local)
* pobierz i zbuduj subchart Kafki
```
helm dependancy update
helm dependency build
```
* zainstgaluj Helm Chart:
```
helm install transaction-service . -f values.yaml
```
* w razie edycji wartości użyj aby wczytać nowododane dane:
```
helm  upgrade --install transaction-service .
```
