# ShortUrl

![MIT](https://img.shields.io/github/license/Youthink/short_url?logo=lightgreen)
![elixir](https://img.shields.io/badge/language-elixir-%234e2a8e)
[![](https://img.shields.io/badge/%E7%B3%BB%E7%BB%9F%E8%AE%BE%E8%AE%A1-%E5%8E%9F%E7%90%86-blue)](https://hufangyun.com/2017/short-url/)

> 短链接生成应用

## 体验

[预览地址](https://fearless-trustworthy-aidi.gigalixirapp.com/)

由 [Gigalixir](https://gigalixir.com/) 提供免费部署服务，该地址只用于体验，:warning: 不提供数据维护存储。

## 预览图

![image](https://user-images.githubusercontent.com/9588284/65018350-77ff9280-d95b-11e9-80fd-8f11010f3e2b.png)

## 系统设计

[短网址(short URL)系统的原理及其实现](https://hufangyun.com/2017/short-url/)

## 准备工作

###  安装elixir

http://elixir-lang.org/install.html

### 安装postgreSQL

## 首次运行

* 安装依赖  `mix deps.get`
* 创建数据库及数据表  `mix ecto.create && mix ecto.migrate`
* 安装前端依赖 `cd assets && yarn install`
* 启动服务 `mix phx.server`
* 访问应用 [`localhost:4000`](http://localhost:4000)

## 调试

进入控制台:

```shell
iex -S mix
```

## 格式化代码

```shell
mix format
```
## 部署

可以参考这篇文章 [使用 edeliver 部署 Elixir 应用程序](https://hufangyun.com/2017/elixir-edeliver/)

## API

**短链接生成 API**

```bash
## api/shorten
curl -X "POST" "http://localhost:4000/api/shorten" \
      -H 'Content-Type: application/json; charset=utf-8' \
      -d $'{
  "url": "https://www.github.com"
}'
```

**批量短链接生成 API**

```bash
## Mutil api/shorten
curl -X "POST" "http://localhost:4000/api/shorten/" \
      -H 'Content-Type: application/json; charset=utf-8' \
      -d $'{
  "url": [
    "https://gitlab.com",
    "https://github.com"
  ]
}'
```

**短链接复原 API**

```bash
## api/original
curl -X "POST" "http://localhost:4000/api/original/" \
      -H 'Content-Type: application/json; charset=utf-8' \
      -d $'{
  "url": "http://localhost:4000/zRa"
}'
```

## 配置

1、部署地址

2、短链域名

## TODO

- [ ] 记录打包、部署、更新测试中的地址

## License

[MIT](http://opensource.org/licenses/MIT)

Copyright (c) 2018-present, 小猿大圣（Youthink）
