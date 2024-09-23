# AlphaB 消息文档
### 本篇内容皆采用Socket连接，以json格式发送数据

**{"type":String , "id":"String" , ...}**

### id

**指令唯一标识符**

## 前端主动请求

### type

| type               | remark     |
| ------------------ | ---------- |
| "connect"          | 连接服务器 |
| "callback"         | 消息回调   |
| "message"          | 文本消息   |
| "image"            | 图片消息   |
| "disposable image" | 闪照消息   |
| "audio"            | 音频消息   |

### connect

{"type":"connect","id":"01", "public key":String}

#### return

{"type":"connect","id":"01" , "AES key":String}

**AES key为使用RSA公钥加密后的base64编码，格式为key:iv**

### message

{"type":"message","id":"02","name":String,  "head color":String, "bubble color":String, "text":String}

| 字段         | 备注                              |
| ------------ | --------------------------------- |
| id           | 唯一标识符                        |
| name         | 昵称                              |
| head color   | 头像颜色                          |
| bubble color | 气泡颜色                          |
| text         | 消息文本(采用AES加密后base64编码) |

### image

{"type":"image","id":"03","name":String,  "head color":String, "bubble color":String, "data": String ,"size":String }

| 字段       | 备注       |
| ---------- | ---------- |
| id         | 唯一标识符 |
| name       | 昵称       |
| head color | 头像颜色   |
| bubble color | 气泡颜色   |
| data       | 图片(base64编码后采用AES加密) |
| size | 尺寸，如"300x400" |

### disposable image

{"type":"disposable image","id":"04","name":String,  "head color":String, "bubble color":String, "data": String}

| 字段       | 备注       |
| ---------- | ---------- |
| id         | 唯一标识符 |
| name       | 昵称       |
| head color | 头像颜色   |
| bubble color | 气泡颜色   |
| data       | 图片(base64编码后采用AES加密) |

### audio

{"type":"audio","id":"05","name":String,  "head color":String, "bubble color":String, "data": String}

| 字段       | 备注       |
| ---------- | ---------- |
| id         | 唯一标识符 |
| name       | 昵称       |
| head color | 头像颜色   |
| bubble color | 气泡颜色   |
| data       | 音频(base64编码后采用AES加密) |

## 前端被动接收

{"type":String, ...}

### message

{"type":"message", "id":String, "name":String, "text":String , "head color":String, "bubble color":String}

| name         | 昵称                        |
| ------------ | --------------------------- |
| text         | 消息（AES加密后base64编码） |
| head color   | 头像颜色                    |
| bubble color | 气泡颜色                    |

### image

{"type":"image", "id":String, "name":String, "data":String , "size":String , "head color":String, "bubble color":String}

| name         | 昵称                          |
| ------------ | ----------------------------- |
| data         | 图片(base64编码后采用AES加密) |
| size         | 尺寸，如"300x400"             |
| head color   | 头像颜色                      |
| bubble color | 气泡颜色                      |

### disposable image

{"type":"disposable image", "id":String, "name":String, "data":String ,"size":String , "head color":String, "bubble color":String}

| name         | 昵称                          |
| ------------ | ----------------------------- |
| data         | 图片(base64编码后采用AES加密) |
| size         | 尺寸，如"300x400"             |
| head color   | 头像颜色                      |
| bubble color | 气泡颜色                      |

### audio

{"type":"audio", "id":String, "name":String, "data":String , "head color":String, "bubble color":String}

| name         | 昵称                          |
| ------------ | ----------------------------- |
| data         | 音频(base64编码后采用AES加密) |
| head color   | 头像颜色                      |
| bubble color | 气泡颜色                      |

## 消息回调

{"type":"callback" , id":"02","status":String}

| status          |                      |
| --------------- | -------------------- |
| "success"       | 成功                 |
| "fail"          | 失败                 |
| "lost"          | 数据不完整，数据丢失 |
| "decrypt error" | 服务端数据解密失败   |
