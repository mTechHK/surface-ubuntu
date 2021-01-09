### Linux Surface

在Microsoft Surface設備上運行的Linux。請按照以下說明安裝最新的內核和配置文件。

### 注意

只是對那些感興趣的人有所了解。我不得不稍微暫停這個項目，但是計劃中有很多大事，這個項目很快就會再次活躍起來！！

### 支援的設備

* Surface Book
* Surface Book 2
* Surface Go
* Surface Laptop
* Surface Laptop 2
* Surface Pro 3
* Surface Pro 4
* Surface Pro 2017
* Surface Pro 6
* Surface Studio

### 可以運作的配件

* 鍵盤（和背光）
* 觸控板
* 2D / 3D加速
* 觸摸屏
* Surface Pen
* 無線上網
* 藍牙
* 電源按鈕
*音量按鈕
* SD卡讀卡器
* 攝像頭（部分支持，暫時禁用）
* 休眠
* 傳感器（加速度計，陀螺儀，環境光傳感器）
* 電池讀數
* 蓋上/打開停靠平板電腦和鍵盤
* 表面碼頭
* DisplayPort
* USB-C（包括HDMI輸出）顯卡
* 某些專用的Nvidia GPU

### 沒辦法運作的配件

*專用的Nvidia 顯卡（除非您具有基於Surface Book 1 ，否則板載Nvidia 就可以正常工作）
*相機（尚不完全支持）
*尚不支持Connected Standby

###免責聲明
*在大多數情況下，事物都是在Surface Book上測試的。雖然據說大多數事情在其他設備上都可以正常使用，但您的行駛里程可能會有所不同。請查看問題列表以了解可能的例外情況。

### 下載預建內核

以下說明中的setup.sh腳本將為您處理下載。否則，您仍然可以直接下載它們（不建議這樣做，因為您將要運行setup.sh腳本）。

基於ubuntu發行版的下載（其他發行版將需要使用隨附的補丁從源代碼進行編譯） : https://github.com/jakeday/linux-surface/releases

您將需要下載要安裝的版本的映像，標頭和libc-dev deb文件。

### 步驟

0. (準備) 安裝必要項:
  使用指令
  ```
   sudo apt install git curl wget sed
  ```
  
1. 複製h這個專案到你的電腦:
  ```
   git clone --depth 1 https://github.com/jakeday/linux-surface.git ~/linux-surface
  ```
  
2. 進入這個專案的路徑:
  ```
   cd ~/linux-surface
  ```
  
3. 使用指令:
  ```
   sudo sh setup.sh
  ```

安裝腳本將為您處理安裝最新內核。您還可以選擇下載所需的任何版本並自行安裝：
安裝標頭，內核和libc-dev（請確保首先將進入(cd)到下載位置）：
  ```
  sudo dpkg -i linux-headers-[VERSION].deb linux-image-[VERSION].deb linux-libc-dev-[VERSION].deb
  ```
  
### 從源代碼編譯內核

#### 對於基於Debian的系統

如果您不想使用預構建的內核和驅動， 則可以按照以下步驟自己編譯內核：

0. (Prep) Install the required packages for compiling the kernel:
  ```
  sudo apt install build-essential binutils-dev libncurses5-dev libssl-dev ccache bison flex libelf-dev
  ```
1. 複製穩定內核:
  ```
  git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git ~/linux-stable
  ```
  
2. 進入linux-stable目錄:
  ```
  cd ~/linux-stable
  ```
  
3. 檢查您要定位的內核版本（替換為目標版本）:
  ```
  git checkout v5.y.z
  ```
  
4. 應用linux-surface存儲庫中的內核補丁（這一步，並假設您將其克隆到〜/ linux-surface中）:
  ```
  for i in ~/linux-surface/patches/[VERSION]/*.patch; do patch -p1 < $i; done
  ```
  
5. 將配置用於內核系列（可能需要手動更改發行版）:
  ```
  cp ~/linux-surface/configs/[VERSION]/config .config
  ```
  
6. 編譯內核和頭文件（對於ubuntu，請參閱發行版的構建指南）:
  ```
  make -j `getconf _NPROCESSORS_ONLN` deb-pkg LOCALVERSION=-linux-surface
  ```
  
7. 安裝headers，內核和libc-dev:
  ```
  sudo dpkg -i linux-headers-[VERSION].deb linux-image-[VERSION].deb linux-libc-dev-[VERSION].deb
  ```

#### 對於Arch-Based的系統

請看[這裡] (https://github.com/dmhacker/arch-linux-surface)

### 簽名內核以進行安全啟動

請查看 [SIGNING.md](SIGNING.md).

### 注意

*如果加載ramdisk時卡住了啟動時間，則需要安裝用於Intel CPU的處理器微代碼固件（通常在“軟件和更新”中的“其他驅動程序”下找到）。
*不要安裝TLP！它可能會導致速度變慢，性能下降以及偶爾掛起！你被警告了。
*如果您選擇在暫停時使用休眠模式，請按照[此處]的說明進行操作（https://fitzcarraldoblog.wordpress.com/2018/07/14/configuring-lubuntu-18-04-to-enable-hibernation-using-a-swap-file/）。

### 支持

如果您對內核有疑問，請隨時在此處創建有問題的跟踪它。如果您有疑問或需要支持，請使用我們的[Gitter社區]（https://gitter.im/linux-surface）！

### 捐款給原作者！

PayPal: https://www.paypal.me/jakeday42

比特幣: 1AH7ByeJBjMoAwsgi9oeNvVLmZHvGoQg68
