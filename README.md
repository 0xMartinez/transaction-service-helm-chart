# Helm chart do wdrożenia aplikacji "System do obsługi transakcji płatniczych w Spring Boot"

Helm chart pozwala na uruchomienie aplikacji w klastrze Kubernetes i jest zgodny z wersjami Kybernetes 1.22+

Wszystkie zmienne wymagające jakiejkolwiek edycji zostały zawarte w pliku values.yaml.
W celu zapewnienia wysokiej dostępności alikacja jest uruchamiana w 2 instancjach.

Wdrożona aplikacja pozwala na edytowanie adresu oraz domeny klastra. Przy pierwszym uruchomieniu oraz przy każdorazowej zmianie adresu/domeny należy dodać wpis do pliku etc/hosts lączący nowy hostname z adresem 1.0.0.127 (localhost):
```
1.0.0.127 transaction-service.local
```
Domyślnie ustawionym adresem jest:
```
hostname: "transaction-service.local"
```
Aplikacja domyślnie tworzy dwa topiki o nazwach wskazanych w values.yaml i przekazuje je do aplikacji Spring przez zmienne środowiskowe zdefiniowane w deployments.yaml. Topiki tworzone są automatycznie podczas startu aplikacji, dlatego może zdarzyć się sytuacja w której po starcie/upgrade aplikacji przez chwilę lista dostępnmych topików będzie pusta: 
```
predefinedTopics: # configuration for Kafka topics name
  completed:
    name: transakcje-zrealizowane
  expired:
    name: transakcje-przeterminowane
```
W sytuacji kiedy wykonywany jest install/upgrade istniejącego wdrożenia, uruchamiany jest job czyszczący topiki Kafki nie będące zdefiniowane w values.yaml
Dotatkowo w kontekście topików, została dodana funkcjonalość "expirowania" wiadomości w topikach kafki. Wartości również znajdują się w values.yaml:
```
    extraConfig: |- # message expiration config in miliseconds
      log.retention.ms: 300000
      log.retention.check.interval.ms: 60000
```
Sama Kafka działa w oparciu o architekturę z zookeeperem i 2 brokerami. Dla poprawy czytelności logów oraz aby niepotrzebnie nie rzucać wyjątkami podczas startu aplikacji, użyty został initContainers czekający na wstanie brokerów kafki. Wszystkie niezbędne wartości wymagające nadpisania oryginalnej konfiguracji, zostały nadpisane w pliku values.yaml. 
Ponieważ domyślnie aplikacja posiada wbudowaną baze danych h2, która w domyślnym trybie jest wbudowana w środowisko aplikacji, potrzebne było zdefiniowanie pvc oraz przestawienie bazy danych w tryb "Server Mode" w celu zdalnego używania bazy danych przez api.
Pozostanie w domyślnym trybie Embedded z wiecej niż jedną repliką aplikacji powodowało, że naprzemiennie w użyciu były 2 odrębne bazy danych.

Poprzez ingress zostały udostępnione endpoint dla wszystkich funkcjonalności (prezentowane wartości, zmienią sie po edycji hostname):
* api do zarządzania transakcjami poprzez swagger: [http://transaction-service.local/swagger-ui/index.html]
* api do zarządzania płatnościami poprzez soap (plik .wsdl został dołączony w głownym katalogu): [http://transaction-service.local/ws]
* actuator (dodany na etapie developmentu helm chartu, użyty do testów, w celu weryfikacji czy aplikacja "wstała" poprawnie): [http://transaction-service.local/actuator/health]
* plik openapi.yaml zawierający definicję wystawionego REST API: [http://transaction-service.local/openapi/openapi.yaml]
* dodatkowo aplikacja udostępnia endpoint konsoli (tutaj konfiguracja ingress nie była wymagana), wymagany jest port forwarding: [http://localhost:8080/h2-console]
```
 kubectl port-forward <nazwa poda> 8080:8080
```

należy przejść w tryb server mode, url: jdbc:h2:file:/data/db/mydb;AUTO_SERVER=TRUE , dla uproszczenia developmentu pola z credentialami nie są wymagane i powinny być puste

Instrukcja uruchomienia
-------------------------------
* wystartuj lokalny klaster Kubernetes
* włącz tunnelowania w celu uzyskania dostępu do wnętrza klastra (przykład)
```
minikube tunnel
```
* dodaj hostname razem z adresem localhosta (domyślnie: 1.0.0.127 transaction-service.local) w celu zasymulowania zewnętrznych usług
* pobierz i zbuduj subchart Kafki
```
helm dependency build
```
* zainstaluj Helm Chart:
```
helm install transaction-service . -f values.yaml
```
* w razie edycji wartości użyj aby wczytać nowododane dane:
```
helm  upgrade --install transaction-service . -f values.yaml
```
* upewnij się że wszystkie pody wstały, następnie uruchom testy:
```
helm test transaction-service
```
