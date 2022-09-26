<#
.OZET
Bu komut dosyası, AD üzerinde yetkili hesap kontrolü yapar.
# LİSANS #
AD Kullanıcı Doğrulama Bildirimi - AD'de yer alan belirli gruba üye olan kullanıcıyı kontrol eder.
Bu program özgür bir yazılımdır: yeniden dağıtabilir ve/veya değiştirebilirsiniz. Bu program yararlı olması ümidiyle dağıtılmaktadır, ancak HİÇBİR GARANTİ YOKTUR.
.VERSION
1.0.0
.YAZAR
Onur Yilmaz
.ORNEK
powershell.exe -ExecutionPolicy Bypass -File ".\Login_View.ps1" -Domain:"YOUR DOMAIN" -ADGroup:"YOUR AD GROUP" -Title:"Kimlik Doğrulaması" -Company:"Onur Yılmaz" -RetryCount:3
.BAĞLANTI
https://onuryilmaz.blog
#>
    
# Define Parameters
[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$True,Position=0)]
    [String]$Domain,

    [Parameter(Mandatory=$True,Position=1)]
    [String]$ADGroup,
    
    [Parameter(Mandatory=$True,Position=2)]
    [String]$Title,

    [Parameter(Mandatory=$True,Position=2)]
    [String]$Company,

    [Parameter(Mandatory=$True,Position=3)]
    [int32]$RetryCount
)


## GLOBAL VARIABLES ##
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$scriptPath = $scriptPath.Replace("\","/")
$Status = $False
if ($RetryCount -lt 0) { $RetryCount = 0 }
elseif ($RetryCount -gt 0) {$RetryCount = $RetryCount - 1}
$global:StatusCount = $RetryCount

## Message Sending Notification
## New-Message -MessageTitle "Status" -Message "The account has been successfully verified."
Function New-Message ($MessageTitle,$Message) {
    $MessageXML = @"
<Window x:Class="WPF_MessageForm.View.MessageView"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WPF_MessageForm.View"
        mc:Ignorable="d"
        Title="WPFMessage" Height="150" Width="300"
        WindowStyle="None"
        ShowInTaskbar="False"
        ResizeMode="NoResize"
        WindowStartupLocation="CenterScreen"
        Background="Transparent"
        AllowsTransparency="True">

    <Border CornerRadius="12">
        <Border.Background>
            <ImageBrush ImageSource="$scriptPath/Images/back-image.jpg"
                        Stretch="None"/>
        </Border.Background>

        <Border CornerRadius="10"                    
            BorderThickness="2"
            Opacity="0.80">

            <Border.BorderBrush>
                <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                    <GradientStop Color="#FF02A8FF" Offset="0"/>
                    <GradientStop Color="Black" Offset="0.50"/>
                    <GradientStop Color="#FF02A8FF" Offset="1"/>
                </LinearGradientBrush>
            </Border.BorderBrush>

            <Border.Background>
                <LinearGradientBrush StartPoint="0,1" EndPoint="1,0">
                    <GradientStop Color="Black" Offset="0"/>
                    <GradientStop Color="Black" Offset="1"/>
                </LinearGradientBrush>
            </Border.Background>

            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="30"/>
                    <RowDefinition/>
                </Grid.RowDefinitions>

                <Grid Grid.Row="0">

                    <Grid.ColumnDefinitions>
                        <ColumnDefinition/>
                        <ColumnDefinition Width="25"/>
                        <ColumnDefinition Width="25"/>
                        <ColumnDefinition Width="5"/>
                    </Grid.ColumnDefinitions>

                    <TextBlock Text="$MessageTitle"
                               Foreground="DarkGray"
                               FontSize="14"
                               FontFamily="Montserrat"
                               Grid.Column="0"
                               VerticalAlignment="Center"
                               Margin="10,0,0,0" IsEnabled="False"/>
                   
                </Grid>
                <StackPanel Width="220"
                            Grid.Row="1"
                            Orientation="Vertical"
                            Margin="0,25,0,0">

                    <TextBlock Text="$Message"
                               Foreground="LightGray"
                               FontSize="12"
                               FontWeight="Medium"
                               FontFamily="Montserrat"
                               TextWrapping="Wrap"
                               TextAlignment="Center"
                               Margin="0,0,0,0"/>

                    <Button x:Name="MessagebtnClose"                          
                            BorderThickness="0"
                            Content="Kapat"
                            Foreground="White"
                            FontSize="11"
                            FontFamily="Montserrat"
                            Cursor="Hand"                           
                            Margin="0,15,0,0">

                        <Button.Style>
                            <Style TargetType="Button">
                                <Setter Property="Background" Value="#FF02A8FF"/>
                                <Style.Triggers>
                                    <Trigger Property="IsMouseOver" Value="True">
                                        <Setter Property="Background" Value="#FF006296"/>
                                    </Trigger>
                                </Style.Triggers>
                            </Style>
                        </Button.Style>

                        <Button.Template>
                            <ControlTemplate TargetType="Button">
                                <Border Width="70" Height="30"
                                        CornerRadius="9"
                                        Background="{TemplateBinding Background}">
                                    <ContentPresenter VerticalAlignment="Center"
                                                      HorizontalAlignment="Center"/>
                                </Border>
                            </ControlTemplate>
                        </Button.Template>
                    </Button>

                    <StackPanel Orientation="Horizontal"
                                HorizontalAlignment="Center"
                                Margin="0,0,0,0"/>

                </StackPanel>

            </Grid>

        </Border>
        
    </Border>

</Window>
 
"@

    $MessageXML = $MessageXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
    [xml]$MesssageXAML = $MessageXML
    #Read XAML
 
    $MessageReader=(New-Object System.Xml.XmlNodeReader $MesssageXAML)
    try{$MessageForm=[Windows.Markup.XamlReader]::Load( $MessageReader )}
    catch{ Write-Host "Unable to load Windows.Markup.XamlReader. invalid XAML code was encountered or .NET FrameWork is missing."}
    $MesssageXAML.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name ($_.Name) -Value $MessageForm.FindName($_.Name) -Scope global }

    Function MessageBtnCloseAction {
        $MessageForm.Close()
    }

    $MessagebtnClose.Add_Click({MessageBtnCloseAction})


    $MessageForm.ShowDialog() | out-null
}

## ERASE ALL THIS AND PUT XAML BELOW between the @" "@ 
$inputXML = @"
<Window x:Class="WPF_LoginForm.View.LoginView"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WPF_LoginForm.View"
        mc:Ignorable="d"
        Title="LoginView" Height="550" Width="800"
        ShowInTaskbar="True"
        WindowStyle="None"
        ResizeMode="NoResize"
        WindowStartupLocation="CenterScreen"
        Background="Transparent"
        AllowsTransparency="True">

    <Border CornerRadius="12">
        <Border.Background>
            <ImageBrush ImageSource="$scriptPath/Images/back-image.jpg"
                        Stretch="None"/>
        </Border.Background>

        <Border CornerRadius="10"                    
            BorderThickness="2"
            Opacity="0.80">

            <Border.BorderBrush>
                <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                    <GradientStop Color="#FF02A8FF" Offset="0"/>
                    <GradientStop Color="Black" Offset="0.50"/>
                    <GradientStop Color="#FF02A8FF" Offset="1"/>
                </LinearGradientBrush>
            </Border.BorderBrush>

            <Border.Background>
                <LinearGradientBrush StartPoint="0,1" EndPoint="1,0">
                    <GradientStop Color="Black" Offset="0"/>
                    <GradientStop Color="Black" Offset="1"/>
                </LinearGradientBrush>
            </Border.Background>

            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="30"/>
                    <RowDefinition/>
                </Grid.RowDefinitions>

                <Grid Grid.Row="0">

                    <Grid.ColumnDefinitions>
                        <ColumnDefinition/>
                        <ColumnDefinition Width="25"/>
                        <ColumnDefinition Width="25"/>
                        <ColumnDefinition Width="5"/>
                    </Grid.ColumnDefinitions>

                    <TextBlock Text="$Title"
                               Foreground="DarkGray"
                               FontSize="14"
                               FontFamily="Montserrat"
                               Grid.Column="0"
                               VerticalAlignment="Center"
                               Margin="10,0,0,0" IsEnabled="False"/> 
                    
                    <Button x:Name="btnMinimize"                           
                            BorderThickness="0"
                            Content="-"
                            Foreground="White"
                            FontSize="16"
                            FontFamily="Montserrat"
                            Cursor="Hand"
                            Grid.Column="1">

                        <Button.Style>
                            <Style TargetType="Button">
                                <Setter Property="Background" Value="#FF675E5E"/>
                                <Style.Triggers>
                                    <Trigger Property="IsMouseOver" Value="True">
                                        <Setter Property="Background" Value="#FF02A8FF"/>
                                    </Trigger>
                                </Style.Triggers>
                            </Style>
                        </Button.Style>

                        <Button.Template>
                            <ControlTemplate TargetType="Button">
                                <Border Width="18" Height="18"
                                        CornerRadius="9"
                                        Background="{TemplateBinding Background}">
                                    <ContentPresenter VerticalAlignment="Center"
                                                      HorizontalAlignment="Center"/>
                                </Border>
                            </ControlTemplate>
                        </Button.Template>
                    </Button>

                    <Button x:Name="btnClose"                          
                                BorderThickness="0"
                                Content="X"
                                Foreground="White"
                                FontSize="12"
                                FontFamily="Montserrat"
                                Cursor="Hand"
                                Grid.Column="2">

                            <Button.Style>
                                <Style TargetType="Button">
                                    <Setter Property="Background" Value="#FF02A8FF"/>
                                    <Style.Triggers>
                                        <Trigger Property="IsMouseOver" Value="True">
                                            <Setter Property="Background" Value="#FF006296"/>
                                        </Trigger>
                                    </Style.Triggers>
                                </Style>
                            </Button.Style>

                            <Button.Template>
                                <ControlTemplate TargetType="Button">
                                    <Border Width="18" Height="18"
                                            CornerRadius="9"
                                            Background="{TemplateBinding Background}">
                                        <ContentPresenter VerticalAlignment="Center"
                                                          HorizontalAlignment="Center"/>
                                    </Border>
                                </ControlTemplate>
                            </Button.Template>
                        </Button>
                </Grid>
                <StackPanel Width="220"
                            Grid.Row="1"
                            Orientation="Vertical"
                            Margin="0,35,0,0">

                    <Image Source="$scriptPath/Images/Logo.png"
                           Width="100" Height="100"/>

                    <TextBlock Text="$Company"
                               Foreground="White"
                               FontSize="25"
                               FontWeight="Medium"
                               FontFamily="Montserrat"
                               HorizontalAlignment="Center"/>

                    <TextBlock Text="Kullanıcı Doğrulaması"
                               Foreground="LightGray"
                               FontSize="12"
                               FontWeight="Medium"
                               FontFamily="Montserrat"
                               TextWrapping="Wrap"
                               TextAlignment="Center"
                               Margin="0,5,0,0"/>


                    <TextBlock Text="Kullanıcı Adı"
                               Foreground="DarkGray"
                               FontSize="12"
                               FontWeight="Medium"
                               FontFamily="Montserrat"                             
                               Margin="0,35,0,0"/>

                    <TextBox x:Name="txtUser"
                             FontSize="13"
                             FontWeight="Medium"
                             FontFamily="Montserrat"                            
                             Foreground="White"
                             CaretBrush="LightGray"
                             BorderBrush="DarkGray"
                             BorderThickness="0,0,0,2"
                             Height="28"
                             VerticalContentAlignment="Center"
                             Margin="0,5,0,0"
                             Padding="20,0,0,0">

                        <TextBox.Background>
                            <ImageBrush ImageSource="$scriptPath/Images/user-icon.png"
                                        Stretch="None"
                                        AlignmentX="Left"/>
                        </TextBox.Background>
                    </TextBox>

                    <TextBlock Text="Şifre"
                               Foreground="DarkGray"
                               FontSize="12"
                               FontWeight="Medium"
                               FontFamily="Montserrat"                             
                               Margin="0,15,0,0"/>

                    <PasswordBox x:Name="txtPass"
                             FontSize="13"
                             FontWeight="Medium"
                             FontFamily="Montserrat"                            
                             Foreground="White"
                             CaretBrush="LightGray"
                             BorderBrush="DarkGray"
                             BorderThickness="0,0,0,2"
                             Height="28"
                             VerticalContentAlignment="Center"
                             Margin="0,5,0,0"
                             Padding="20,0,0,0">

                        <PasswordBox.Background>
                            <ImageBrush ImageSource="$scriptPath/Images/key-icon.png"
                                        Stretch="None"
                                        AlignmentX="Left"/>
                        </PasswordBox.Background>
                    </PasswordBox>

                    <Button x:Name="btnLogin"                          
                            BorderThickness="0"
                            Content="Oturum Aç"
                            Foreground="White"
                            FontSize="12"
                            FontFamily="Montserrat"
                            Cursor="Hand"                           
                            Margin="0,50,0,0">

                        <Button.Style>
                            <Style TargetType="Button">
                                <Setter Property="Background" Value="#FF02A8FF"/>
                                <Style.Triggers>
                                    <Trigger Property="IsMouseOver" Value="True">
                                        <Setter Property="Background" Value="#FF006296"/>
                                    </Trigger>
                                </Style.Triggers>
                            </Style>
                        </Button.Style>

                        <Button.Template>
                            <ControlTemplate TargetType="Button">
                                <Border Width="150" Height="40"
                                        CornerRadius="20"
                                        Background="{TemplateBinding Background}">
                                    <ContentPresenter VerticalAlignment="Center"
                                                      HorizontalAlignment="Center"/>
                                </Border>
                            </ControlTemplate>
                        </Button.Template>
                    </Button>

                    <StackPanel Orientation="Horizontal"
                                HorizontalAlignment="Center"
                                Margin="0,0,0,0"/>

                </StackPanel>

            </Grid>

        </Border>
        
    </Border>

</Window>
 
"@
 
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML

## Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{ Write-Host "Unable to load Windows.Markup.XamlReader. invalid XAML code was encountered or .NET FrameWork is missing."}
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name) -Scope global }

## Close (X) button command location
Function BtnCloseAction {
    $Form.Close()
}

## Shrink (-) button command location
Function BtnMinimizeAction {
    $Form.WindowState = "Minimized"
}

## AD user control command location
Function ADUserCheck {
    [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | out-null
    $DomainName = "$Domain" 
    # add type to allow validating credentials
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    
    # Create the Domain Context for authentication
    $ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain

    # We specify Negotiate as the Context option as it takes care of choosing the best authentication mechanism i.e. Kerberos or NTLM (non-domain joined machines).
    $ContextOptions = [System.DirectoryServices.AccountManagement.ContextOptions]::Negotiate
    try { $PrincipalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext($ContextType, $DomainName)  } catch { New-Message -MessageTitle "Bağlantı başarısız!" -Message "Lütfen şirket ağında olup olmadığınızı kontrol edin."; $Form.Close() }
    if (($txtUser.Text -eq "") -or ($txtPass.Password -eq "")) {
        if ($txtUser.Text -eq "") {
            New-Message -MessageTitle "Eksik Bilgi Girişi!" -Message "Lütfen kullanıcı adı ve şifre giriniz."
            $txtUser.Text = ""
            $txtPass.Password = ""
        }
        elseif ($txtPass.Password -eq "") {
            New-Message -MessageTitle "Eksik Bilgi Girişi!" -Message "Lütfen şifre giriniz."
        } 
    }
    Elseif ($PrincipalContext.ValidateCredentials($txtUser.Text, $txtPass.Password, $ContextOptions) -eq $true)
    {
        $Status = $True
        $GroupMembers = ([ADSISEARCHER]"samaccountname=$($txtUser.Text)").Findone().Properties.memberof -replace '^CN=([^,]+).+$','$1'
        if ($GroupMembers -like "*$ADGroup*") {
            New-Message -MessageTitle "Başarılı!" -Message "Hesap başarıyla doğrulandı."
            $Form.Close()
        }
        else {
            if ($global:StatusCount -gt 0) { New-Message -MessageTitle "Yetki Hatası!" -Message "Kullanıcı yetkisi bulunmamaktadır.&#10;&#13;Kalan deneme sayısı: $global:StatusCount" }
            $global:StatusCount--
            if ($global:StatusCount -lt 0) {
                $Form.Close()
            }
            else {
                $txtUser.Text = ""
                $txtPass.Password = ""
            }
        }
    }
    else {
        $Status = $False
        if ($global:StatusCount -gt 0) { New-Message -MessageTitle "Kullanıcı Bilgi Hatası!" -Message "Kullanıcı adı veya şifre hatalı !&#10;&#13;Kalan hatalı deneme sayısı: $global:StatusCount" }
        $global:StatusCount--
        if ($global:StatusCount -lt 0) {
            $Form.Close()
        }
        else {
            $txtUser.Text = ""
            $txtPass.Password = ""
        }
    }
}

$btnLogin.Add_Click({ADUserCheck})
$btnClose.Add_Click({BtnCloseAction})
$btnMinimize.Add_Click({BtnMinimizeAction})


$Form.ShowDialog() | out-null