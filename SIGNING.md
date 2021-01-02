### 簽名自定義內核以進行安全啟動

這一則說明是針對ubuntu的，但如果其他版本使用的是shim，則說明應該類似
和grub作為引導程序。如果您的發行版未使用填充程序（例如Linux Foundation Preloader），
應該以相似的步驟完成簽名（例如，對於LF Preloader，使用HashTool代替MokUtil）
或者您可以安裝補丁以代替使用。 shim的ubuntu軟件包稱為“ shim-signed”，但
請告知自己如何正確安裝它，以免弄亂引導加載程序。

由於Ubuntu中的最新GRUB2更新（2.02 + dfsg1-5ubuntu1），GRUB2不會加載未簽名的文件
只要啟用了安全啟動，內核就不再可用。 Ubuntu 18.04的用戶將在以下期間收到通知
升級grub-efi軟件包，表明該內核未簽名，升級將中止。

因此，您有三種選擇來解決此問題：

1.自己簽名內核。
2.使用發行版的簽名的通用內核。
3.禁用安全啟動。

由於選項2和3並不是真正可行，因此這些是您自己簽名內核的步驟。

從[Ubuntu博客]（https://blog.ubuntu.com/2017/08/11/how-to-sign-things-for-secure-boot）改編的說明。
在執行以下操作之前，請備份您的/ boot / EFI目錄，以便您可以還原所有內容。跟隨這些步驟需要您自擔風險。

1. Create the config to create the signing key, save as mokconfig.cnf:
```
# 如果沒有HOME資料夾，此定義將阻止以下行執行
# defined.
HOME                    = .
RANDFILE                = $ENV::HOME/.rnd 
[ req ]
distinguished_name      = req_distinguished_name
x509_extensions         = v3
string_mask             = utf8only
prompt                  = no

[ req_distinguished_name ]
countryName             = <YOURcountrycode>
stateOrProvinceName     = <YOURstate>
localityName            = <YOURcity>
0.organizationName      = <YOURorganization>
commonName              = Secure Boot Signing Key
emailAddress            = <YOURemail>

[ v3 ]
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always,issuer
basicConstraints        = critical,CA:FALSE
extendedKeyUsage        = codeSigning,1.3.6.1.4.1.311.10.3.6
nsComment               = "OpenSSL Generated Certificate"
```
請根據您的需求更改以上配置！

2. 創建用於簽名內核的公鑰和私鑰：
```
openssl req -config ./mokconfig.cnf \
        -new -x509 -newkey rsa:2048 \
        -nodes -days 36500 -outform DER \
        -keyout "MOK.priv" \
        -out "MOK.der"
```

3. 還將密鑰也轉換為PEM格式（mokutil需要DER，sbsign需要PEM）：
```
openssl x509 -in MOK.der -inform DER -outform PEM -out MOK.pem
```

4. 將密鑰註冊到補丁安裝中：
```
sudo mokutil --import MOK.der
```
系統會要求您輸入密碼，只需使用它來確認您在[
下一步，所以選擇任何一個。

5.重新啟動系統。您將遇到一個名為MOKManager的工具的藍屏。
選擇“Enroll MOK”，然後選擇“View key”。確保它是您在步驟2中創建的密鑰。
然後繼續該過程，您必須輸入您提供的密碼
步驟4.繼續引導系統。

6. 通過以下方式驗證您的密鑰是否已註冊：
```
sudo mokutil --list-enrolled
```

7. 對已安裝的內核進行簽名（應位於/ boot / vmlinuz- [KERNEL-VERSION] -surface-linux-surface）：
```
sudo sbsign --key MOK.priv --cert MOK.pem /boot/vmlinuz-[KERNEL-VERSION]-surface-linux-surface --output /boot/vmlinuz-[KERNEL-VERSION]-surface-linux-surface.signed
```

8. 複製未簽名內核的initram，因此我們也為已簽名內核提供了一個initram。
```
sudo cp /boot/initrd.img-[KERNEL-VERSION]-surface-linux-surface{,.signed}
```

9. 更新您的grub-config
```
sudo update-grub
```

10. 重新引導系統，然後選擇已簽名的內核。如果啟動有效，則可以刪除未簽名的內核：
```
sudo mv /boot/vmlinuz-[KERNEL-VERSION]-surface-linux-surface{.signed,}
sudo mv /boot/initrd.img-[KERNEL-VERSION]-surface-linux-surface{.signed,}
sudo update-grub
```

現在，您的系統應該在已簽名的內核下運行，並且升級GRUB2可以再次進行。如果你想
要升級自定義內核，您可以按照上述步驟輕鬆簽署新版本
從第七步開始。因此，備份MOK鍵（MOK.der，MOK.pem，MOK.priv）。
