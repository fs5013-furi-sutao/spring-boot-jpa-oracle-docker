# Spring Boot + JPA, Oracle: Build CRUD App

このチュートリアルでは、Hibernate、Spring Data JPA を使用して CRUD 操作を行う Spring Boot および Oracle データベース接続を作成する。

## Technology

- Java 11
- Spring Boot 2(with Spring Web MVC, Spring Data JPA)
- Oracle 19c
- Gradle

## 概要

- Oracle Database と連携するように Spring Data JPA、Hibernate を構成する方法
- データモデルとリポジトリインターフェイスを定義する方法
- HTTP リクエストを処理する Spring Rest Controller を作成する方法
- Spring Data JPA を使用して Oracle Database と対話する方法

## 作成する API 一覧

- 各 Tutotial には、ID、タイトル、説明、公開ステータスがある
- API を使うことで、チュートリアルの作成、取得、更新、削除ができる
- API は公開ステータスやタイトルによる検索などのカスタム検索メソッドもサポートしている
  
| メソッド | URL                            | 行動                                                      |
| :------- | :----------------------------- | :-------------------------------------------------------- |
| POST     | /api/tutorials                 | 新しいチュートリアルを作成する                            |
| GET      | /api/tutorials                 | すべてのチュートリアルを取得する                          |
| GET      | /api/tutorials/:id             | :id のチュートリアルを取得する                            |
| PUT      | /api/tutorials/:id             | :id のチュートリアルを更新する                            |
| DELETE   | /api/tutorials/:id             | :id のチュートリアルを削除する                            |
| DELETE   | /api/tutorials                 | すべてのチュートリアルを削除する                          |
| GET      | /api/tutorials/publish         | 公開されているすべてのチュートリアルを検索                |
| GET      | /api/tutorials?title=[keyword] | タイトルに含まれるすべてのチュートリアルを keyword で検索 |

Hibernate と Spring Data JPA の JpaRepository を使って、CRUD 操作や検索メソッドを作る。

## プロジェクト構成

``` console
apt update
apt-get install tree
```

`実行結果: `
```
.
├── build.gradle
└── src
    └── main
        ├── java
        │   └── com
        │       └── example
        │           └── demo
        │               ├── SpringBootOracleApplication.java
        │               ├── controller
        │               │   └── TutorialController.java
        │               ├── model
        │               │   └── Tutorial.java
        │               └── repository
        │                   └── TutorialRepository.java
        └── resources
            └── application.properties
```

簡単に説明する。

- Tutorial data model クラスは、Tutorial エンティティと Tutorial テーブルに対応している
- TutorialRepository は JpaRepository を拡張したインターフェースで、CRUD メソッドとカスタム検索メソッドに対応している。これは TutorialController で Autowired される。
- TutorialController は RESTful なリクエストに対応する RestController で、getAllTutorials, createTutorial, updateTutorial, deleteTutorial, findByPublished... などのリクエストマッピングメソッドを持つ
- application.properties には、Spring Datasource、JPA、Hibernate の設定がある
- build.gradle には、Spring Boot と Oracle の依存関係が含まれている。

## Create & Setup Spring Boot project

VSCode の Spring Initializr Java Support 拡張機能を使用して、Spring Boot Gradle プロジェクトを作成する。

build.gradle を開いて以下の依存関係を追加する。

`build.gradle`
``` groovy
plugins {
	id 'org.springframework.boot' version '2.6.1'
	id 'io.spring.dependency-management' version '1.0.11.RELEASE'
	id 'java'
}

group = 'com.example'
version = '0.0.1-SNAPSHOT'
sourceCompatibility = '11'

repositories {
	mavenCentral()
}

dependencies {
	implementation 'org.springframework.boot:spring-boot-starter-web'
	implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
	implementation 'com.oracle.database.jdbc:ojdbc10:19.7.0.0'
	implementation 'javax.persistence:javax.persistence-api:2.2'
	developmentOnly 'org.springframework.boot:spring-boot-devtools'
	testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

test {
	useJUnitPlatform()
}
```

## Spring and Oracle database connection Configuration

`src/main/resources` ディレクトリ内の application.properties を開き、
Spring Data Source、JPA/Hibernate を設定する。

設定値は Docker コンテナで設定した環境変数を利用する。

`application.properties`
```
spring.datasource.url=jdbc:oracle:thin:@${DB_HOST_NAME}:${INNER_DB_PORT_NO}/${ORACLE_PDB}
spring.datasource.username=${DB_USER_NAME}
spring.datasource.password=${DB_USER_PWD}
spring.datasource.driver-class-name=oracle.jdbc.OracleDriver

# Hibernate ddl auto (create, create-drop, validate, update)
spring.jpa.hibernate.ddl-auto=update
```

- spring.datasource.username と spring.datasource.password のプロパティは、インストールされているデータベースと同じものを使用する
- Spring Boot は JPA の実装に Hibernate を使用しているので、Oracle には oracle.jdbc.OracleDriver を設定する

### spring.jpa.hibernate.ddl-auto について

spring.jpa.hibernate.ddl-auto は、データベースの初期化に使用される。

この値を update に設定することで、定義されたデータモデルに対応するテーブルが自動的にデータベースに作成される。
モデルが変更されると、テーブルの更新も行われる。本番環境では、このプロパティは validate にする。

## データモデルの定義

データモデルは Event で、id，title，description，published の4つのフィールドを持っている。
model パッケージで Event クラスを定義する。

`model/Tutorial.java`
``` java
package com.example.demo.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "events")
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private long id;

    @Column(name = "title")
    private String title;

    @Column(name = "description")
    private String description;

    @Column(name = "published")
    private boolean published;

    public Event() {

    }

    public Event(String title, String description, boolean published) {
        this.title = title;
        this.description = description;
        this.published = published;
    }

    public long getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isPublished() {
        return published;
    }

    public void setPublished(boolean isPublished) {
        this.published = isPublished;
    }

    @Override
    public String toString() {
        return "Event [id=" + id + ", title=" + title + ", desc=" + description + ", published=" + published + "]";
    }

}
```

- @Entity アノテーションは、このクラスが永続的な Java クラスであることを示す
- @Table アノテーションは、このエンティティをマッピングする Oracle テーブルを示す
- @Id アノテーションは主キーを示す
- @GeneratedValue アノテーションは、主キーの生成戦略を定義するために使用される。GenerationType.AUTO は自動増分フィールドを意味する
- @Column アノテーションは、注釈付きフィールドをマッピングする Oracle データベースの列を定義するために使用される

## Repository インタフェースの作成

Oracle データベースのテーブルから Events を操作するためのリポジトリを作成する。
Repository パッケージ内に、JpaRepository を拡張した EventRepository インターフェースを作成する。

`repository/EventRepository.java`
``` java
package com.example.demo.repository;

import java.util.List;

import com.example.demo.model.Event;

import org.springframework.data.jpa.repository.JpaRepository;

public interface EventRepository extends JpaRepository<Event, Long> {
    List<Event> findByPublished(boolean published);

    List<Event> findByTitleContaining(String title);
}
```

これで、JpaRepository のメソッドである 
save()、findOne()、findById()、findAll()、count()、delete()、deleteById()...  を、
これらのメソッドを実装せずに使用できるようになる。

## Spring Rest APIs Controller を作成

最後に、Tutorial の作成、取得、更新、削除、検索のための API を提供するコントローラを作成する。

`controller/EventController.java`
``` java
package com.example.demo.controller;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import com.example.demo.model.Event;
import com.example.demo.repository.EventRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@CrossOrigin(origins = "http://localhost:8080")
@RestController
@RequestMapping("/api")
public class EventController {

    @Autowired
    EventRepository eventRepository;

    @GetMapping("/events")
    public ResponseEntity<List<Event>> getAllEvents(
            @RequestParam(required = false) String title) {
        try {
            List<Event> events = new ArrayList<Event>();

            if (title == null)
                eventRepository.findAll().forEach(events::add);
            else
                eventRepository.findByTitleContaining(title)
                        .forEach(events::add);

            if (events.isEmpty()) {
                return new ResponseEntity<>(HttpStatus.NO_CONTENT);
            }

            return new ResponseEntity<>(events, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/events/{id}")
    public ResponseEntity<Event> getEventById(@PathVariable("id") long id) {
        Optional<Event> tutorialData = eventRepository.findById(id);

        if (tutorialData.isPresent()) {
            return new ResponseEntity<>(tutorialData.get(), HttpStatus.OK);
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    @PostMapping("/events")
    public ResponseEntity<Event> createEvent(@RequestBody Event event) {
        try {
            Event _event = eventRepository.save(
                    new Event(event.getTitle(), event.getDescription(), false));
            return new ResponseEntity<>(_event, HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PutMapping("/events/{id}")
    public ResponseEntity<Event> updateEvent(@PathVariable("id") long id,
            @RequestBody Event tutorial) {
        Optional<Event> eventData = eventRepository.findById(id);

        if (eventData.isPresent()) {
            Event _event = eventData.get();
            _event.setTitle(tutorial.getTitle());
            _event.setDescription(tutorial.getDescription());
            _event.setPublished(tutorial.isPublished());
            return new ResponseEntity<>(eventRepository.save(_event),
                    HttpStatus.OK);
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    @DeleteMapping("/events/{id}")
    public ResponseEntity<HttpStatus> deleteEvent(@PathVariable("id") long id) {
        try {
            eventRepository.deleteById(id);
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @DeleteMapping("/events")
    public ResponseEntity<HttpStatus> deleteAllEvents() {
        try {
            eventRepository.deleteAll();
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }

    }

    @GetMapping("/events/published")
    public ResponseEntity<List<Event>> findByPublished() {
        try {
            List<Event> events = eventRepository.findByPublished(true);

            if (events.isEmpty()) {
                return new ResponseEntity<>(HttpStatus.NO_CONTENT);
            }
            return new ResponseEntity<>(events, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
```

- CrossOrigin では、許可されるオリジンを設定する
- RestController アノテーションは、コントローラを定義し、メソッドの戻り値を Web レスポンスボディにバインドすることを示すために使用する
- RequestMapping("/api") は、コントローラ内のすべての APIU の URL が `/api` で始まることを宣言している
- EventRepository Bean をローカル変数に注入するために @Autowired を使用している

## Run & Check Oracle database

以下のコマンドで Spring Boot アプリを起動させる。

``` console
./gradlew bootRun
```

# API の動作確認

Chrome 拡張
Talend API Tester - Free Edition

## Create some Events:

`POST: `
`http://localhost:8080/api/events`
``` json
{
  "id": 6,
  "title": "Create API Tut#6",
  "description": "Tut#6 Description"
}
```

`Response: `
`201`
```
{
  "id": 5,
  "title": "Create API Tut#6",
  "description": "Tut#6 Description",
  "published": false
}
```

## Update some Events:

`PUT: `
`http://localhost:8080/api/events/2`
``` json
{
  "title": "Oracle Database (new) Tut#2",
  "description": "Desc for Tut#2",
  "published" : true
}
```

`Response: `
`200`
```
{
  "id": 2,
  "title": "Oracle Database (new) Tut#2",
  "description": "Desc for Tut#2",
  "published": true
}
```

## Get all Events:

`GET: `
`http://localhost:8080/api/events`

`Response: `
`200`
```
[
  {
    "id": 5,
    "title": "Create API Tut#6",
    "description": "Tut#6 Description",
    "published": false
  },
  {
    "id": 1,
    "title": "Spring Boot Tut#1",
    "description": "Tut#1 Description",
    "published": false
  },
  {
    "id": 2,
    "title": "Oracle Database (new) Tut#2",
    "description": "Desc for Tut#2",
    "published": true
  },
  {
    "id": 3,
    "title": "Spring Hibernate Oracle Tut#3",
    "description": "Tut#3 Description",
    "published": false
  },
  {
    "id": 4,
    "title": "Spring Data JPA Tut#4",
    "description": "Tut#4 Description",
    "published": false
  }
]
```

## Get a Events by Id:

`GET: `
`http://localhost:8080/api/events/3`

`Response: `
`200`
```
{
"id": 3,
"title": "Spring Hibernate Oracle Tut#3",
"description": "Tut#3 Description",
"published": false
}
```

## Find all published Events:

`GET: `
`http://localhost:8080/api/events/published`

`Response: `
`200`
```
[
  {
    "id": 2,
    "title": "Oracle Database (new) Tut#2",
    "description": "Desc for Tut#2",
    "published": true
  }
]
```

## Find all Events which title contains ‘ring’:

`GET: `
`http://localhost:8080/api/events?title=ring`

`Response: `
`200`
```
[
  {
    "id": 1,
    "title": "Spring Boot Tut#1",
    "description": "Tut#1 Description",
    "published": false
  },
  {
    "id": 3,
    "title": "Spring Hibernate Oracle Tut#3",
    "description": "Tut#3 Description",
    "published": false
  },
  {
    "id": 4,
    "title": "Spring Data JPA Tut#4",
    "description": "Tut#4 Description",
    "published": false
  }
]
```

## Delete a Events:

`DELETE: `
`http://localhost:8080/api/events/4`

`Response: `
`204`
```
```
