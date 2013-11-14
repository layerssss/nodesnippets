# wanalytic

## 环境

* nodejs `brew install nodejs`
* mysql `brew install mysql`
* git `brew install git`
* foreman `brew install ruby && gem install foreman` 

## 安装依赖

```
make
```

## 配置数据库

* 数据库schema在`scripts/wanalytic.sql`里
* 随机生成填充数据`npm run-script populate`

## 启动

```
foreman start
```

## 配置（环境变量）

* `MYSQL_URI`: 数据库URI，默认为`mysql://localhost/wanalytic`
