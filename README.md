# 租赁商城app

## 生产环境的线上版本

目前的iOS线上版本号为1.0.10，对应的git branch为`master`
带用户充值功能的分支为`develop`

## 注意事项

如果发生无法真机安装调试或无法adhoc安装时，记得检查`project.pbxproj`中的`provision profile`和`code sign`设置

## 开发环境

flutter 1.22.2

## app icon的生成

[https://appicon.co/](https://appicon.co/)

## Android和iOS的安装包

* 运行`flutter build apk`生成production的apk
* 在xcode下build->archive，然后根据是adhoc/app store选择对应的选项和profile

> 注意：如果是adhoc的测试版，ios需要将ipa重新命名成onezu.ipa上传到阿里云的对象存储OSS
> Android需要将apk重新命名成onezu.apk上传

## iOS app 发布

### Certificates, Identifiers & Profiles部分

1. 登录apple developer账号(https://developer.apple.com)[https://developer.apple.com]
2. 点击Certificates, Identifiers & Profiles
3. 按"+"添加新Certificates
4. 选择iOS distribution(App Store and Ad Hoc)
5. 创建CSR(Certificate Signing Request)：
    a. 启动位于 /Applications/Utilities 中的“钥匙串访问”
    b. 选取“钥匙串访问”>“证书助理”>“从证书颁发机构请求证书”
    c. 在“证书助理”对话框中，在“用户电子邮件地址”栏位中输入电子邮件地址(changshawanzu@163.com)
    d. 在“常用名称”栏位中，输入密钥的名称 (例如onezu adhoc key)(onezu adhoc key)
    e. 将“CA 电子邮件地址”栏位留空
    f. 选取“存储到磁盘”，然后点按“继续”
6. 将生成的csr上传，然后continue
7. 下载生成好的certificate，然后双击安装
8. 保存该certificate的私钥：
    a. 打开钥匙串访问
    b. 左边侧边栏，钥匙串->登录，种类->密钥
    c. 找到onezu adhoc key的专有密钥
    d. File->Export，存储为.p12格式
9. 再次登录apple developer账号
10. 选择Certificates, Identifiers & Profile->Identifiers，点击"+"创建新的app ID
    * 选择app IDs
    * 输入Bundle ID: `com.onezu.rentingEverything`
    * 勾选`Associated Domains`和`Push Notifications`

11. 选择Certificates, Identifiers & Profiles->Profiles，点击"+"创建provisioning profile
12. 由于是超级签名，此处选择adhoc(如果是正常发布到app store, 当然选择app store, 或者如果是企业签名，则选择in house)
13. 根据提示步骤一路继续，记得选择之前创建的app ID和certificate，最后下载创建好的provisioning profile
14. 下载的profile名称是mobileprovision，需要修改成onezu.mobileprovision(也就是mobileprovision必须作为文件后缀名，否则xcode无法导入)

### 推送通知

推送通知使用的是极光推送[https://www.jiguang.cn/](https://www.jiguang.cn/)
极光推送的ios推送证书的设置请参照[https://docs.jiguang.cn/jpush/client/iOS/ios_cer_guide/](https://docs.jiguang.cn/jpush/client/iOS/ios_cer_guide/)

### Xcode部分

1. 打开xcodeproj项目
2. 选中该工程文件，然后在从左数起的第二列的`TARGETS`下面，选中Runner（或万租，取决于是否已经重命名该app）
3. 在正上方选中Siging & Capabilities，
    a. 取消选择`Automatically manage signing`，
    b. 输入对应的bundle identifier（即app id）
    c. 通过import profile或者download profile选择对应的provisioning profile
4. 在xcode最上标题栏的左边，选择`Generic iOS Device`
5. 菜单栏->Product->Archive，耐心等待完成编译，codesign会提示输入系统的登录密码
6. Distribute App->AdHoc
7. App Thinning->none，next
8. 选择对应的certificate和provisioning profile
9. export

> 注意：在真机运行的时候，如果是Mac连接iphone通过xcode安装，在Targets->Runner->Signing & Capabilities，需要勾选`Automatically manage signing`，这样Xcode就会自动选择Development的provision profile，如果此时用iOS distribution的provision profile安装调试，会提示"unable to install runner"

## iOS universal links

### 设置：

原生app的微信登录需要用到iOS的universal links功能，也就是从其他app（比如微信）直接跳转打开本app（万租）的功能。具体的设置步骤如下：

1. 生成ios/apple-app-site-association文件，填写正确的team ID+bundle ID(可在developer.apple.com的app IDs中找到)，要求必须支持https
    > 注意：如果要将https://bms.piizu.com/ulink设置为universal link的话，在`apple-app-site-association`中的paths应该填写为["ulink/*"]而不是["/ulink/*"]
2. 将该文件上传到服务器的根目录或者.well-known目录，也就是确保https://bms.piizu.com/apple-app-site-association或者https://bms.piizu.com/.well-known/apple-app-site-association可以打开该文件
    > 注意：服务器的域名必须支持https
3. 在developer.apple.com的app IDs中，确保associated domains已经打开
4. 在xcode中的Signing & capabilities中+ capability->associated domains，添加`applinks:bms.piizu.com`，这里只填写域名而不是完整的url
5. 在xcode中的build phases->copy bundle resources中，添加上一个步骤中自动生成的entitlements文件

### 测试：

当在ios设备上安装好本app后，打开Safari，打开`https://bms.piizu.com/ulink`，然后下来，如果顶部出现"用万租打开"，证明universal links设置成功



## 技术栈

* 移动端：Flutter v1.22.2
* 后端：Golang/MongoDB

## 自定义图标的使用

* 将所有图标以svg的格式从figma中导出
* 去fluttericon.com，拖到custom icons里面
* 选择所有拖进去的图标，在名称处输入`RentingApp`，然后下载
* 下载好的文件中，将RentingApp.ttf拷贝至assets/fonts文件夹
* 将renting_app_icons.dart拷贝至lib文件夹

## Android应用签名的生成

```shell
keytool -genkey -alias onezu -keyalg RSA -validity 10000 -keystore onezu.keystore
keytool -importkeystore -srckeystore onezu.keystore -destkeystore onezu.keystore -deststoretype pkcs12
```

查看应用签名：

```shell
keytool -list -v -keystore onezu.keystore
```
得到MD5：7B:39:77:40:50:EF:86:25:95:4A:0F:BC:6E:37:02:DE，去掉所有的":"，并且将所有的大写改成小写就是应用签名

应用签名为
7b39774050ef8625954a0fbc6e3702de

在生成应用签名后，下一步就是为应用的debug和release apk签名，这个可以由`build.gradle`自动完成，详见`android/app/build.gradle`里的`signingConfigs`和`buildTypes`，具体的keystore文件的配置在`android/key.properties`中

## 设计

### 设计稿

设计稿是用Figma完成的，请使用robbie_com@hotmail.com的Google账号登录查看，名称为`zuhuan`

## 备忘录

### 关于ICP证（互联网信息经营许可证）

详见阿里云关于代办ICP证的说明[https://tm.aliyun.com/channel/product/icp?spm=5176.10695662.1265906.3.3805550e1bFhOp]
里面说明了“企业的主要经营业务，如果包括在线销售服务、在线点击支付”则需要办理ICP证，所以最好还是咨询律师确保到底是否需要办理该证

## 进程

1. 已申请阿里云账号，实名企业认证通过
    * 已经购买wonzu.top作为域名，域名和模版审核都已经通过
    * 申请备案服务号需要先购买服务器，购买服务器又需要阿里云的企业实名认证，目前只能等待：
      1. 阿里云的企业实名认证通过，或者
      2. 拿到企业对公银行账号信息后，填入企业支付宝，企业支付宝实名通过后再进行阿里云的企业实名认证
2. 已申请微信开放平台，正在申请移动应用，但是审核被拒，目前正在申请实名认证
    * 没有选择对应的应用类目，因为没有租赁行业的相关选择，审核拒绝原因说是先要认证主体
    * iOS的应用Bundle ID和Android的应用包名都是`com.onezu.rentingEverything`
    * iOS的universal_links是`https://bms.piizu.com/ulink/`
    * Android的应用签名是`7b39774050ef8625954a0fbc6e3702de`
    * 移动应用审核通过后，就是开通微信支付，需要先申请微信商户号
> 注意：移动应用审核失败，需要先认证主体，具体步骤是：`账号中心->开发者资质认证->现在申请`。需要企业开户行信息...
3. 已申请企业支付宝，已经通过企业认证的资料人工审核，已经填写对公账号，接下来需要从对公账号中打款到支付宝公司
    * 在企业支付宝认证后，参考[https://opendocs.alipay.com/open/204/105297](https://opendocs.alipay.com/open/204/105297)登录支付宝开放平台创建应用
4. 云片网实名审核已通过，审核签名和模版也已经通过
5. 极光推送已经实名认证并且整合

> 注意：为了方便开发，使用派族网络的微信开放平台和企业支付宝的开放平台都已经申请微信支付和支付宝支付了，正在审核当中（申请于2020年9月11日）

## SDK接入注意事项

### 微信SDK

* 在万租的微信移动应用准备就绪后，有两个地方需要修改：
  * Xcode->TARGETS->info->URL type->URL Schemes，填写万租的微信移动应用app ID
  * flutter的代码中`fluwx.registerWxApi`处也要改成万租的微信移动应用app ID
* 在微信商户号中要设置商户API密钥，在账户中心->API安全 里面设置，这个API密钥在微信支付时需要用到，具体在GoRenting/config/config.prod.json和GoRenting/config/config.local.json设置
* 在config.prod.json和config.local.json中还需要设置微信开放平台中创建的应用的app ID和app密钥
* `GoRenting/config/config.prod.json`和`GoRenting/config/config.local.json`中的`serverIP`在重新部署服务器后也需要修改
* 等到域名备案成功后，还需要修改universalLink

### 支付宝SDK

* 区支付宝开放平台注册、实名认证后，同样需要创建新的移动应用
* 实名认证后会有个账号ID（后端config文件中的pID），在账号中心查看
* 移动应用申请通过后会生成app id(后端config文件中的appID)
* 公钥证书的生成：
  * 打开“支付宝开放平台开发助手”, 生成密钥->获取CSR文件->点击获取
  * 弹窗选项分别选择`RSA2`和`PKCS1`
  * 组织/公司务必填写与支付宝开放平台实名认证的企业名称一致
  * 生成后点击"打开文件位置"，会有一个公钥文件、一个私钥文件和一个csr文件，将这三个文件拷贝至后端文件夹中的`cert/alipay`文件夹中
  * 私钥文件的名称需要填写至后端`config/config.prod.json`和`config/config.local.json`中的alipay->privateKeyFile
  * 登录支付宝开放平台，控制台->我的应用->网页&移动应用->点击对应的应用
  * 点击左边栏的“应用信息“，接口加签方式->设置/查看
  * 选择加签方式为公钥证书，然后“上传CSR文件在线生成证书“上传刚才生成的CSR文件
  * 下载三个证书，分别是应用公钥证书、支付宝根证书和支付宝公钥证书
  * 将这三个证书拷贝至`~/Projects/GoRenting/cert/alipay`文件夹
  * 将这三个证书文件的名称填写至后端`config/config.prod.json`和`config/config.local.json`的`alipay`对应栏位
> 注意：支付宝app支付签约未满90天，余额要到账的第二天才能结算

### 极光推送

* 在重新申请长沙万租的apple开发者账号后，需要重新生成各种证书，其中包括开发推送证书和生产推送证书，这两个证书需要在极光推送中重新上传，具体位置为：登录极光的应用运营平台->应用管理->右边的应用设置->左边中间的推送设置->去设置->iOS->证书配置
* Flutter代码中jpush的setup使用的是`production: false`，服务器端用API推送消息时记得保持一致
* 免费版的极光推送的广播每天只能发送10条，只能明天接着测试了

### 极光统计

* 当整合janalytics flutter的时候，打包android apk的时候会出错，需要将janalytics的build.gradle的minSdkVersion和compileSdkVersion修改到与jpush的build.gradel中的一致

## BUG:

1. ios app无法下载
2. 极光错误日志显示了iOS闪退的原因（修改了代码，但不确定是否已经修复，继续关注吧）
3. 在获取电池状态和位置的时候，还没有整合科金博厂家的，"未知的电池BMS厂家"
4. 退租的订单在分配给服务人员后，服务人员在“我的工单”列表中无法看到
5. iOS卡顿，经过查验是证书OCSP的问题

## BUG修复

## 已修改部分
7. 后台管理界面中的订单列表和订单详情现在会显示电池IMEI号码
8. 退租流程大修改，将退款变成线上，具体流程如下：
   1. 用户提交退租后，后台将该订单分配给服务人员
   2. 服务人员上门回收后，将该电池返回至仓库，服务码找后台管理人员要
   3. 服务人员填写服务码和电池IMEI号完成退租订单后，该订单的状态变成“等待退款中”
   4. 具体的退款操作由后台管理人员在“等待退款中”的订单详情中完成，退款的金额为全部押金
9. 当用户的电池已经有一个正在等待上门的服务单时，禁止再针对该电池创建新的服务单
10. APP中统一成用户协议、租赁协议、服务政策
11. 商品类别现在可以修改了
12. 退租时不能再开服务单，有服务单时不能发起退租
13. 新增一个工单管理版块，分配给服务人员的工单不再和订单混合在一起
    1. 当将一个服务单/退租单分配给服务人员，系统自动生成一个新工单
    2. 如果一个已经分配了服务人员的订单被分配给另一个服务人员，之前的工单被取消，同时系统为新分配的服务人员创建一个新工单
    3. 当用户取消服务单/退租单时，已分配的工单自动被系统取消，该工单变成"已取消"
    4. 当服务人员完成工单时，该工单变成“已完成”的状态

## 新增
1. 后台管理中可以手动修改电池的状态
2. 更换电池后原订单的电池没有更新的bug已经修复
3. 有时完成工单时会报错的bug已经修复
4. 电池管理添加分类管理：按照状态分为闲置中、正在租赁中、退租检测中、故障返修中、已报失。按照保护板厂家分为明唐、科金博
5. 电池状态的变更：
   1. 电池默认是闲置中
   2. 安装给用户的电池变成“正在租赁中”
   3. 换回来的电池变成“故障返修中”
   4. 退租后返回来的电池变成“退租检测中”
   5. 确认退款后电池变成“闲置中”
   6. 在完成工单时，如果新安装的电池不是处于“闲置中”，该工单无法完成
6. 后台管理中的续租订单也要可以查看电池IMEI和用户信息，另外续租订单的截止日期错误
7. 电池现在可以设定一个自己的编码
8. 多个电池可以通过上传EXCEL文件导入，在“电池管理版块”点击“上传电池列表文件”，仅支持.xlsx后缀的EXCEL文件，具体的格式参见battery_list_sample.xlsx

待修改：
* 服务政策改为勾选可读，而不是每次都要读一遍
* 为防止误操作，订单状态修改的功能将从后台管理中删除
* 所有列表添加批量操作（删除）
* 即将到期的订单要提醒用户续租，如果用户不续租，到期的时候要
  * 自动断电
  * 自动生成退租订单

## TODO

1. 后端对前端提交的输入的sanitization
2. 所有button都必须防止二次提交，具体参见enterPassword的_sendingLoginRequest
3. 在提交http请求或者从后端读取数据时，要有loading动画
4. 极光推送在iOS的生产环境下收不到推送消息

## 需要新增的功能

1. 用户之间的推广和返现（后续功能）
2. 用户钱包功能，可充值、可提现（需要有充值协议）
3. 宣传网页的设计、宣传活动的设计
4. 商店首页的设计、商品详情页的设计
5. 定位功能，flutter插件[https://pub.dev/packages/geolocator]
6. 微信分享
7. 加了一个新功能，一次订100台电池，针对经销商客户
8. 对电池添加tag，便于后台搜索和管理

## TODO

1. Apple developer开发者账号的购买
2. 软件著作权的申请
3. Android各大应用市场的上架
4. 注册商标
5. 购买云片网的短信额度(已完成)
6. 购买身份证验证的API额度(已完成)
7. 设计和实现app下载页面

