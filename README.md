# QQ connect plugin for Discourse / Discourse QQ 互联插件

Authenticate with discourse with qq connect.

通过 QQ 互联登陆 Discourse。

## Register Client Key & Secert / 申请 QQ 接入

1. 登录 [QQ Connect](http://connect.qq.com/)，注册填写相关信息。
2. 进入`管理中心`，点击`创建应用`，选择`网站`。
3. 填写相关信息。`网站地址`应填写论坛所处的位置。`回调地址`应填写根域名位置。如图所示。（验证所需要的标签可在 Discourse 设置中插入，验证后即可删除；访问 Discourse 管理面板 - 内容 - 页面顶部）
4. 找到刚申请到的应用，在左上角找到`id`和`key`，分别填入 Discourse 设置中的 `client_key` 和 `client_secret`。

<img src="https://meta.discourse.org/uploads/default/34523/414f622b202bba06.png" width="583" height="500">

## Installation / 安装

在 `app.yml` 的

    hooks:
      after_code:
        - exec:
            cd: $home/plugins
            cmd:
              - mkdir -p plugins
              - git clone https://github.com/discourse/docker_manager.git

最后一行 `- git clone https://github.com/discourse/docker_manager.git` 后添加：

    - git clone https://github.com/fantasticfears/qq_connect.git

## Usage / 使用

Go to Site Settings's login category, fill in the client id and client secret.

进入站点设置的登录分类，填写 client id 和 client serect。

## Issues / 问题

Visit [topic on Discourse Meta](https://meta.discourse.org/t/qq-login-plugin-qq/19718) or [GitHub Issues](https://github.com/fantasticfears/qq_connect/issues).

访问[中文论坛上的主题](https://meta.discoursecn.org/t/qq/42)或[GitHub Issues](https://github.com/fantasticfears/qq_connect/issues)。

## Changelog

Current version: 0.4.0

0.3.0: 修正没有正确保存 uid 的 bug。
0.4.0: 包含登录策略 gem，去掉下载外部 gem 的步骤。

<img src="https://meta.discourse.org/uploads/default/34493/dc792b8ba0ca145a.png" width="690" height="386">

<img src="https://meta.discourse.org/uploads/default/34492/62b8bfde277857af.png" width="690" height="312">

<img src="https://meta.discourse.org/uploads/default/34494/ea6c21600bd68279.png" width="690" height="330">

<img src="https://meta.discourse.org/uploads/default/34495/eaf2d4fae5f6a64c.png" width="690" height="313">
