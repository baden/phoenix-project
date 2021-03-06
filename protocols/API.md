## Поля информации о системе

- **last_ping** - Метка последнего выхода на связь с сервером.
- **expect_ping** - Время в секундах следующего выхода на связь, относительно поля **last_ping**.
  Значение очень приблизительное.


## Основные положения

Основной протокол обмена - Websocket.
После установки соединения, необходимо отправить токен сессии.

```json
{
    "cmd" : "login",
    "token" : "@TOKEN"
}
```

Сервер, если токену сессии соответствует зарегестрированный и аутентифицированный пользователь,
регистрирует подписку на поле account/@USER_KEY и присылает текущее значение поля:

```json
{
    "cmd" : "document",
    "collection" : "account",
    "value" : {
        "id" : "$USER_ID",
        "username" : "User",
        "systems" : ["$SYS_ID1", "$SYS_ID2"]
    }
}
```

Если для токена сессии не соответствует пользователя или пользователь вышел из учетной записи, или срок действия токена вышел, или если токен заблокирован,
то сервер присылает запрос на авторизацию:

```json
{
    "cmd" : "error",
    "resource" : "token",
    "code" : "missing_auth"
}
```

## Авторизация пользовтеля

Для авторизации пользователя, необходимо отправить имя пользователя и хеш пароля (MD5).

```bash
    echo -n "5uper_Pa55w0rD" | md5sum
```

`05fda46f58a2bf325167f3109ab5d407`

```json
{
    "cmd" : "auth",
    "data" : {
        "username" : "Username",
        "password" : "05fda46f58a2bf325167f3109ab5d407"
    }
}
```

Если пользователь с указанными именем не существует,
или был указан неверный пароль, то будет возвращено:

```json
{
    "cmd" : "error",
    "resource": "token",
    "code": "invalid_credentials"
}
```


## Регистрация нового пользовтеля

Для регистрации нового пользователя, необходимо отправить имя пользователя и хеш пароля (MD5).

```bash
    echo -n "5uper_Pa55w0rD" | md5sum
```

`05fda46f58a2bf325167f3109ab5d407`

```json
{
    "cmd" : "register",
    "data" : {
        "username" : "Username",
        "password" : "05fda46f58a2bf325167f3109ab5d407"
    }
}
```

Создается токен для авторизации, сервер примсылает:

```json
{
    "cmd" : "token",
    "value" : "$TOKEN"
}
```

Клиент должен сохранить значение в памяти и отправить токен для авторизации (см выше).




## Удержание соединения

Если в течении минуты WEB-клиент не присылает ни одного сообщения,
то сервер присылает пакет данных для удержания соединения:

```json
{
    "cmd" :"ping",
    "timestamp": 123455678
}
```


## Добавление системы в список наблюдения

Добавление системы производится в два этапа:

1. Запрос на добавление.

Если система еще не привязана к какому-то пользователю,
то процедура привязки производится следующей последовательностью:

1.1. Подается запрос на привязку:

```json
{
    "cmd" : "start_link_system",
    "system" : {
        "field" : "IMEI",
        "value" : "NNNNNN"
    },
    "confirm_phone" : "+380671234567"
}
```

При следующем выходе системы на связь, сервер сообщит ей
что инициирована процедура привязки. Если система
позволяет привязку, то она генерирует код подтверждения,
оправляет его на телефон `confirm_phone` и на сервер
(см. протокол обменя системы и сервера).
Приложение оправляет подтверждение привязки:

```json
{
    "cmd" : "confirm_link_system",
    "code" : "1245"
}
```

Если код подтверждения верный, то сервер добавит систему
в список наблюдения. И пришлет документ:

```json
{
    "cmd" : "document",
    "collection" : "system",
    "value" : {
        "id" : "$SYS_ID1",
        "title" : "Моя машина",
        "registered" : 1234567878,
        "last_position" : {
            "lat" : 35.48,
            "lon" : 48.12,
            "dt" : 123452323,
            "speed" : 70.5,
            "direction" : 48,
            ....
        },
        "last_session" : {
            "dt" : 12345577,
            "event" : "log"
        }
    }
}
```

## Изменение документов

Приложение может отправлять на сервер запрос на изменение
полей документа:

```json
{
    "cmd" : "update_document",
    "collection" : "system",
    "query" : [
        {
            "key" : "system_id",
            "path" : "title",
            "value" : "Машина сына"
        }
    ]
}
```

Если разрешено изменение указанного поля, то сервер пришлет
(полный) документ с измененным значением поля.
Если изменение поля не разрешено, то сервер может прислать
соответстующее информационное сообщение.

## Динамическое обновление документов.

Присланные сервером документы ("collection" : "document"),
автоматически будут доставлены если они изменились на сервере.


## Информационные сообщения от сервера

Сервер может присылать информационные сообщения, которые
будут отображаться в виде всплывающих окон, или другим
удобным способом. Эти сообщения не требуют подтверждения
о прочтении, и не сохраняются в базе данных или в памяти
приложения.

```json
{
    "cmd" : "info",
    "value" : {
        "text" : "Изменять название разрешено только администратору!"
    }
}
```

`TODO`: В будущем данная команда будет изменена для поддержки интернационального вывода.



## Команды администратора ресурса

Данные команды недоступны в продакщене. Используются исключительно для отладки.

### Принудительное добавление системы в список наблюдения.

```json
{
    "cmd" : "admin",
    "admin_cmd" : "document_update",
    "collection" : "account",
    "systems" : {
        "$push" :"$SYS_ID"
    }
}
```


## Добавлени трекера в список наблюдения

Добавление осуществляется в два этапа.

1. Подача заявки на добавление.

На трекер отправляется SMS: link.

Трекер отправляет на сервер запрос на добавление:

```
/{API_ROOT}/link?id={SYS_ID}
```

На что сервер, генерирует уникальный код подтверждения,
и возвращает его трекеру в ответ.

Трекер пересылает код подтверждения на номер, с которого был запрос,
или на номер администратора, если таковой задан.

Приложение отправляет запрос на добавление системы в список наблюдения:

```json
{
    "cmd" : "link",
    "code" : "12-34-56-78"
}
```

Если код верный, то происходит правка документа `account` и всем
подписчиками присылается обновленный документ.

Если код не верный или устарел, то будет возвращена ошибка:

```json
{
    "cmd" : "error",
    "resource": "link_code",
    "code": "invalid_credentials"
}
```

## Изменение порядка систем в списке наблюдения а также удаление трекера из списка наблюдения.

Данная команда используется как для изменения порядка систем в списке наблюдения,
так и для удаления систем из спика.

В целом, эта команда аналогичка команде обновления документа.


```json
{
    "cmd" : "update_document",
    "collection" : "account",
    "query" : [
        {
            "path" : "systems",
            "value" : ["id1", "id2", "id3"]
        }
    ]
}
```


## Режимы и состояния системы и достумные режимы для переключения.

Система может находиться в одном или нескольких режимах работы.
Например, это может быть режим "Сон" (sleep).

```json
{
    "cmd" : "document",
    "collection" : "system",
    "value" : {
        "id" : "$SYS_ID1",
        ...
        "state" : {
                "current" : "sleep",
                "available" : ["force", "lock"],
        },
        "wait_state" : "force"
    }
}
```

Для смены режима работы системы, можно отправить запрос.

```json
{
    "cmd" : "system_state",
    "id" : "$SYS_ID1",
    "value" : "force"
}
```

При этом сервер установит поле states.main.wait_for в значение "force".
При следующем сеансе связи, сервер оповестит систему о нобходимости смены
режима работы на "force". После того, как система прищлет новое сосниние,
совпадающее с полем "wait_for", сервер удалит это поле из записи о системе.

```
CHANGE_STATE:main:force
```

Система может присылаеть на сервер свое состояние режима работы в любом запросе:

```
{POINT_SERVER}/addlog?imei={SYS_ID}&state=S&state_available=FL
```

(прим: Запрос протокола navi.cc)

Для отмены процедуры режима работы системы, можно отправить запрос.

```json
{
    "cmd" : "system_mode",
    "id" : "$SYS_ID1",
    "mode" : "main",
    "value" : ""
}
```

По пустому значению в поле "value", сервер удалит это значение из записи о системе.

## Следующий сеанс связи.

Система, при сеансе связи, может сообщить серверу через какое (примерно) время
будет следующий сеанс связи. Значение указывается в минутах.


```
{POINT_SERVER}/addlog?imei={SYS_ID}&next_session=1440
```

WEB-клиенту документ будет прислан следующего вида:

```json
{
    "cmd" : "document",
    "collection" : "system",
    "value" : {
        "id" : "$SYS_ID1",
        "last_session" : {
            "dt" : 12345577,
            "event" : "log",
            "next" : 1440
        }
    }
}
```
