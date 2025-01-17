# . $PSSCRIPTROOT\get-untisClassTeacherTeams.ps1 # Functions for reading from UNtis 
# (nur für Tests, sofern nicht schon geladen über diklabu)
#
#####                                   DIKLABU_NEXTCLOUDVWN.PSM1
##### Dieses Modul muss mit Powershell x64 (7.1 und höher) interpretiert werden wegen invoke-webrequest -custommethod
##### Es enthält Funktionen, um mit der Nextcloud zu kommunizieren
# get-NCparameters: Liest die Systemparameter für die Nextcloudfunktionen aus
# get-LoginCreds: Liest die Credentials für den angegebenen User entweder aus Datei, aus Konfiguration oder per Benutzereingabe aus
# new-NCfolder: Legt einen Ordner in der Nextcloud an
# set-NCuserShare: Teilen eines Nextcloud Ordners oder Datei
# get-NCuserShares: Get Shares from a specific file or folder
# delete-NCuserShare: Delete Share from a specific file or folder
# new-NCuserIDlist: Create a list of Nextcloud User IDs from Nextcloud
# test-NCpath: Test if a file or folder exists in Nextcloud
# upload-NCfile: Upload a file to Nextcloud
# new-NCfolders: Create a folder structure in Nextcloud for every class
# is-Under18: Prüft, ob ein SoS minderjährig ist
# new-classList: Erstellt eine Klassenliste mit Daten aus BBS-Planung und Active Directory des Schulnetzes
# new-NCclassLists: Erstellt csv-Listen, ähnlich wie Klassenlisten mit E-mail in BBS Planung und legt sie in der Nextcloudstruktur der Klasse ab
   
# ************************************** get-NCparameters ************************************ #
<#
.Synopsis
   Liest die Systemparameter für die Nextcloudfunktionen aus
.DESCRIPTION
   Liest die Systemparameter für die Nextcloudfunktionen aus einer json-Datei aus 
   oder legt diese mit Defaultwerten an, wenn die Datei nicht existiert. Default-
   verzeichnis ist das Benutzerverzeichnis des angemeldeten Benutzers. 
   Defaultdateiname ist ncParams.json.
.PARAMETER file
   Parameterdatei für alle Nextcloud VWN Dienste
.EXAMPLE
   get-NCparameters
.EXAMPLE
   get-NCparameters -file c:\Temp\keys
#>
function get-NCparameters
{
    [CmdletBinding()]
    Param
    (
        # Parameterdatei für alle Nextcloud VWN Dienste
        [Parameter(Position=0)]
        $file="$env:USERPROFILE\ncParams.json"
    )
    Begin {}
    Process {
        $ncParams=@{}
        if (Test-Path $file) {
            $pf = Get-Content $file | ConvertFrom-Json
            $pf.PSObject.Properties | ForEach-Object {$ncParams[$_.Name]=$_.Value}
        }
        else{
            if ($global:ncParams) {
                $global:ncParams.Clear()
            }
            $ncParams.add('allgCsvDelimiter',';')
            $ncParams.add('allgLogfile', "$env:USERPROFILE\ncactions.txt") # logfile NC

            # $ncParams.add('BPpathBbsPlan', "c:\access\plan") # BBS-Planung base directory
            $ncParams.add('BPBackupRootDir', "C:\access\plan\Backup") # Verw.-Netz TS: D:\Programme\BBS-Planung\Sicherung

            $ncParams.add('CWAteachersClasses', "$env:USERPROFILE\cwaTeachersClasses.csv") # file to store list of teachers and organizational units in cwa

            $ncParams.add('EMAILsender', "nextcloudvwl@mmbbs.de") # E-Mail Sender (From:)
            $ncParams.add('EMAILadminUser', "vwl\nextcloudvwl") # E-Mail Admin User
            $ncParams.add('EMAILadminPass', "") # just a placeholder, PW is stored in a securefile after first entry
            $ncParams.add('EMAILpassFile',"$env:USERPROFILE\email.txt") # secure file to save creds nextcloud
            $ncParams.add('EMAILbodyFile',"$env:USERPROFILE\emailbody.txt") # emailbody text, text included in <> is variable
            $ncParams.add('EMAILsubject',"<Klasse>: Änderung von Daten der Lernenden") # email subject, text included in <> is variable
            $ncParams.add('EMAILserver',"ex.mmbbs.de") # Exchange server mmbbs.de
            $ncParams.add('EMAILport',"587") # smtp port

            $ncParams.add('LDAPmm-bbsURI', '172.31.0.41:389') # LDAP server in schoolnet to get students email addresses
            $ncParams.add('LDAPuserName', 'ldap-user') # Username for access to LDAP Server
            $ncParams.add('LDAPuserPass', '') # LDAP secure PW temporary
            $ncParams.add('LDAPuserCredsFile', "$env:USERPROFILE\lu.txt") # LDAP creds secure file
            $ncParams.add('LDAPsusFilePath', "$env:USERPROFILE\ldapSuS.csv") # list of student information from LDAP
            $ncParams.add('LDAPlulFilePath', "$env:USERPROFILE\ldapLuL.csv") # list of teacher information from LDAP

            
            $ncParams.add('NCuriDav','https://nextcloud.mmbbs.de/remote.php/dav/files/799264EF-ADE2-4469-8F70-73A00944C255') # webdav keadmin
            $ncParams.add('NCuriOcsShares', 'https://nextcloud.mmbbs.de/ocs/v2.php/apps/files_sharing/api/v1/shares')
            $ncParams.add('NCuriOcsUsers', 'https://nextcloud.mmbbs.de/ocs/v1.php/cloud/users')
            $ncParams.add('NCrootFolderName', "/Klassen")
            $ncParams.add('NCsusListenFolderName', "Betriebs- und Lernendenlisten")
            $ncParams.add('NCadminUser', "keadmin") # Nextcloud Admin User
            $ncParams.add('NCadminPass', "") # just a placeholder, PW is stored in a securefile after first entry
            # Das App Passwort kann aus Sicherheitsgründen in Nextcloud nur einmal direkt nach der Erstellung angezeigt werden
            $ncParams.add('NCpassFile',"$env:USERPROFILE\nc.txt") # secure file to save creds nextcloud
            $ncParams.add('NClistOfAdditionalSharers', "HR,SO,OP,SR") # Users beyond class team who get global access
            $ncParams.add('NCtextMinderjaehrig', 'Minderjährig')
            $ncParams.add('NCtextErwachsen', '')
            $ncParams.add('NCpathOldClassLists', "$env:USERPROFILE\NColdClassLists") # folder to compare new and old lists
            $ncParams.add('NCpathNewClassLists', "$env:USERPROFILE\NCnewClassLists") # to evaluate if both differ

            $ncParams.add('WUlocation', "https://borys.webuntis.com/WebUntis/jsonrpc.do?school=MMBbS%20Hannover") # webuntis url
            $ncParams.add('WUuser', "kemmrieskurs") # Webuntis user to access data with
            $ncParams.add('WUpass', "") # just a placeholder, PW is stored in a securefile after first entry
            $ncParams.add('WUpassFile',"$env:USERPROFILE\wu.txt") # secure file to save creds webuntis
            $ncParams.add('WUlocationClassTeachers', "$env:USERPROFILE\classesTeachers.csv") # csv file with classes and their teacher team
            $ncParams.add('WUclassesTeachersDelimiter',',') # Separator between teachers in classteacherlist

            $ncParamsString = $ncParams | ConvertTo-Json
            $ncParamsString | Set-Content -Path $file
        }
        $global:ncParams=$ncParams;
        # sicherstellen, dass die Passwörter in den Dateien vorhanden sind
        $tempcreds = get-LoginCreds -userKey "NCAdminUser" -passKey "NCadminPass" -passFileKey "NCpassFile"
        $tempcreds = get-LoginCreds -userKey "EMAILadminUser" -passKey "EMAILadminPass" -passFileKey "EMAILpassFile"
        $tempcreds = get-LoginCreds -userKey "LDAPuserName" -passKey "LDAPuserPass" -passFileKey "LDAPuserCredsFile"
        $tempcreds = get-LoginCreds -userKey "WUuser" -passKey "WUpass" -passFileKey "WUpassFile"
        $tempcreds | Out-Null # just to avoid unused variable warning
    
        return $ncParams;
    }
}
# ************************************** end get-NCparameters ************************************ #
# ************************************** get-LoginCreds ************************************ #
<#
.Synopsis
   Liest die Credentials für den angegebenen User entweder aus Datei, aus Konfiguration oder 
   per Benutzereingabe aus
.DESCRIPTION
   Liest die Credentials für den angegebenen User entweder aus Datei, aus Konfiguration oder 
   per Benutzereingabe aus.

.EXAMPLE
   get-LoginCreds -userKey $userConfigKey -passKey $passConfigKey -passfileKey $passFilenameConfigKey
#>
function get-LoginCreds {
    [CmdletBinding()]
    Param
    (
        # Username Key in global Config
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
                [String]$userKey, 
        # Pasword Key in global Config
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
                [String]$passKey,
                # Pasword Key in global Config
        [Parameter(Mandatory=$true,
                    ValueFromPipelineByPropertyName=$true,
                    Position=2)]
                [String]$passFileKey
    )
    Begin {}
    Process {    
        # Konfigdaten einlesen, wenn notwendig
        if (!$global:ncParams.NCpassFile) { # hier muss ein existierender Subparameter eingetragen sein (z.B. "allgemein"), um auf Vorhandensein zu prüfen
            get-NCparameters # Konfigdaten laden
        }

        if (!(test-path($global:ncParams.$passFileKey))) {
            # input admin pw 
            $global:ncParams.$passKey = ((Get-Credential -username $global:ncParams.$userKey -Message "Passwort für User $userKey eingeben:").password | ConvertFrom-SecureString)
            # and store in secure file
            $global:ncParams.$passKey > $global:ncParams.$passFileKey
        }
        else {
            $global:ncParams.$passKey = Get-Content -Path $global:ncParams.$passFileKey
        }
        $pw = $global:ncParams.$passKey | ConvertTo-SecureString

        $creds = New-Object System.Management.Automation.PSCredential $global:ncParams.$userKey, $pw
        return $creds
    }
}
# ************************************** end get-LoginCreds ************************************ #
# ************************************** new-NCfolder ************************************ #
<#
.Synopsis
   Legt einen Ordner in der Nextcloud an
.DESCRIPTION
   Legt einen Ordner in der Nextcloud an, falls dieser noch nicht existiert
.PARAMETER rootfoldername
    Basisverzeichnis, in dem der neue Ordner angelegt werden soll
    Angabe ohne das WebDAV-Basisverzeichnis
    Default ist "/"
.PARAMETER newfoldername
    Name des anzulegenden Ordners
    vorhandende führendes oder schließendes / wird entfernt
.EXAMPLE
   new-NCfolder "/basefolder" "newfolder"
#>
function new-NCfolder {
    Param
    (
        # Basefolder to start from
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
                [String]$rootfoldername="/", 
        # New folder name
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
                [String]$newfoldername
    )
    Begin{
        # Zusammengefasst bereitet dieser Code-Abschnitt die notwendigen 
        # Authentifizierungsinformationen vor, um sichere HTTP-Anfragen an Nextcloud, 
        # zu ermöglichen.
        $funcName = $MyInvocation.InvocationName # wie heißt diese Funktion?

        $adminuser=(get-LoginCreds -userKey "NCAdminUser" -passKey "NCadminPass" -passFileKey "NCpassFile").UserName
        $apppass= ConvertFrom-SecureString -SecureString (get-LoginCreds -userKey "NCAdminUser" -passKey "NCadminPass" -passFileKey "NCpassFile").Password -AsPlainText
        $headers = @{ 
            "Authorization" = "Basic $([Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("${adminuser}:${apppass}"))))"
        }
    }
    Process {
        $newfoldername=$newfoldername.TrimStart("/")
        $newfoldername=$newfoldername.TrimEnd("/")
        if ($rootfoldername -eq "/"){
            $uri=$global:ncParams['NCuriDav'].TrimEnd("/")+$rootfoldername+$newfoldername
        }
        else{
            $rootfoldername=$rootfoldername.TrimStart("/")
            $rootfoldername=$rootfoldername.TrimEnd("/")
            $uri=$global:ncParams['NCuriDav'].TrimEnd("/")+"/"+$rootfoldername+"/"+$newfoldername
        }
        # Folder schon vorhanden?
        $folderexists=test-NCpath -Uri $uri

        if (!$folderexists){
            Try {
                $inv=Invoke-WebRequest -Uri $uri -customMethod 'MKCOL' -headers $headers
             }
            catch {
                write-msg -msg "$funcName : Folder kann nicht angelegt werden: $uri" -path_prot $global:ncParams['allgLogfile']| Out-Null
            } 
        }  
    }
} 
# ************************************** end new-NCfolder ************************************ #
# ************************************** set-NCuserShare ************************************ #
<#
.Synopsis
   Teilen eines Nextcloud Ordners oder Datei
.DESCRIPTION
    Share a file/folder with a user/group or as public link.

    Syntax: /shares
    Method: POST
    POST Arguments: path - (string) path to the file/folder which should be shared
    POST Arguments: shareType - (int) 0 = user; 1 = group; 3 = public link; 4 = email; 6 = federated cloud share; 7 = circle; 10 = Talk conversation
    POST Arguments: shareWith - (string) user / group id / email address / circleID / conversation name with which the file should be shared
    POST Arguments: publicUpload - (string) allow public upload to a public shared folder (true/false)
    POST Arguments: password - (string) password to protect public link Share with
    POST Arguments: permissions - (int) 1 = read; 2 = update; 4 = create; 8 = delete; 16 = share; 31 = all (default: 31, for public shares: 1)
    POST Arguments: expireDate - (string) set a expire date for public link shares. This argument expects a well formatted date string, e.g. ‘YYYY-MM-DD’
    POST Arguments: note - (string) Adds a note for the share recipient.
    POST Arguments: attributes - (string) URI-encoded serialized JSON string for share attributes
    Mandatory fields: shareType, path and shareWith for shareType 0 or 1.
    Result: XML containing the share ID (int) of the newly created share
    Statuscodes:
    100 - successful
    400 - unknown share type
    403 - public upload was disabled by the admin
    404 - file couldn’t be shared
.PARAMETER itemPath
    Name der Ressource ohne WebDAV Basis URI, z.B. /Klassen/FISI21F
.PARAMETER userID
    Nextcloud UserID für die der Zugriff geschaffen werden soll
.EXAMPLE
   set-NCuserShare -path "Klassen/FISI23D"
#>
function set-NCuserShare {
    Param
    (
        # Folder or file to be shared
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
                [String]$itemPath, # without WebDAV Base URI, e.g. FISI21F
        # Nextcloud User ID
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
                [String]$userID
    )
    Begin{
        $funcName = $MyInvocation.InvocationName # wer bin ich?

        $adminuser=(get-LoginCreds -userKey "NCAdminUser" -passKey "NCadminPass" -passFileKey "NCpassFile").UserName
        $apppass= ConvertFrom-SecureString -SecureString (get-LoginCreds -userKey "NCAdminUser" -passKey "NCadminPass" -passFileKey "NCpassFile").Password -AsPlainText

        $headersDav = @{
            "Authorization" = "Basic $([Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("${adminuser}:${apppass}"))))";
        }
        $headersOcs = @{
            "OCS-APIRequest" = "true";
            "Authorization" = "Basic $([Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("${adminuser}:${apppass}"))))";
        }
    }
    Process {
        $error.clear()
        if (!($itemPath.StartsWith("/")) -and $itemPath -ne "/"){
            $itemPath="/"+$itemPath
        }
        $uri=($global:ncParams['NCuriDav']).TrimEnd("/")+$itemPath
        # Folder/ File exists?
        $folderexists=test-NCpath -Uri $uri

        if ($folderexists){
            $body= @{
                'shareType'=0;
                'shareWith'=$userID;
                'permissions'=31;
                'path'=$itemPath;
            }
            Try {
                 write-msg -msg  "$funcName : gebe Zugriff an userID $userid für $itempath" -path_prot $global:ncParams['allgLogfile']| Out-Null
                 $inv=Invoke-WebRequest -uri $global:ncParams['NCuriOcsShares'] -headers $headersOcs -Method 'POST' -Body $body
                 return $true
            }
            catch {
                write-msg -msg  "$funcName : Fehler bei Invoke-Webrequest: $uri" -path_prot $global:ncParams['allgLogfile']| Out-Null
                return $false
            } 
        }
        else{
            write-msg -msg  "$funcName : Datei/ Folder existiert nicht: $uri" -path_prot $global:ncParams['allgLogfile']| Out-Null
            return $false
        }
    }
} 
# ************************************** end set-NCuserShare ************************************ # 
# ************************************** get-NCuserShares ************************** #
<#
.Synopsis
    Get Shares from a specific file or folder
.DESCRIPTION
    Get all shares from a given file/folder.
    Syntax: /shares
    Method: GET
    URL Arguments: path - (string) path to file/folder
    URL Arguments: reshares - (boolean) returns not only the shares from the current user but all shares from the given file.
    URL Arguments: subfiles - (boolean) returns all shares within a folder, given that path defines a folder
    Mandatory fields: path
    Result: XML with the shares
    Statuscodes:
    100 - successful
    400 - not a directory (if the ‘subfile’ argument was used)
    404 - file doesn’t exist
.EXAMPLE
   get-NCuserShares -path "Klassen/FISI23D"
.EXAMPLE
   get-NCuserShares -path "Klassen/FISI23D" -reshares $false
#>
function get-NCuserShares {
    Param
    (
        # Folder or file to be shared
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
                [String]$itemPath, # with Base URI, e.g. /Klassen/FISI24F
        # Nextcloud User ID
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
                [Boolean]$reshares=$true
    )
    Begin{
        $funcName = $MyInvocation.InvocationName # wer bin ich?
        $adminuser=(get-LoginCreds -userKey "NCAdminUser" -passKey "NCadminPass" -passFileKey "NCpassFile").UserName
        $apppass= ConvertFrom-SecureString -SecureString (get-LoginCreds -userKey "NCAdminUser" -passKey "NCadminPass" -passFileKey "NCpassFile").Password -AsPlainText

        $headersDav = @{
            "Authorization" = "Basic $([Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("${adminuser}:${apppass}"))))";
        }
        $headersOcs = @{
            "OCS-APIRequest" = "true";
            "Authorization" = "Basic $([Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("${adminuser}:${apppass}"))))";
        }
    }
    Process {
        $error.clear()
        if (!($itemPath.StartsWith("/")) -and $itemPath -ne "/"){
            $itemPath="/"+$itemPath
        }
        $uri=$global:ncParams['NCuriDav']+$itemPath
        # Folder/ File exists?
        $folderexists=test-NCpath -Uri $uri

        if ($folderexists){
            $resharesString ="TRUE"
            if (!$reshares) {$resharesString="FALSE"}
            $url=$global:ncParams['NCuriOcsShares'] + "?" + "path=" + $itemPath + "&" + "reshares=" + $resharesString
            Try {
                 write-msg -msg  "$funcName : requesting user shares for file $itempath from server ..." -path_prot $global:ncParams['allgLogfile']| Out-Null
                 write-msg -msg  "$funcName : building list of share_with IDs for file/ folder $itempath ..." -path_prot $global:ncParams['allgLogfile']| Out-Null
                 $sharesList=@{}
                 foreach ($element in ([xml]$inv.content).ocs.data.element){
                     $sharesList.add($element.share_with, $element.id)
                 }
                 return $sharesList
            }
            catch {
                write-msg -msg  "$funcName : Error while Invoke-Webrequest: $uri" -path_prot $global:ncParams['allgLogfile']| Out-Null
                return $false
            } 
        }
        else{
            write-msg -msg  "$funcName : File/ folder doesn't exist: $uri" -path_prot $global:ncParams['allgLogfile']| Out-Null
            return $false
        }
    }
}
# ************************************** end get-NCuserShares ************************************ #

# ************************************** delete-NCuserShare ************************************ #
<#
.Synopsis
    Delet Share from a specific file or folder
.DESCRIPTION
    Delete a share from a given file/folder.
    Syntax: /shares
    Method: DELETE
    URL: path - (string) path to file/folder
    Statuscodes:
    100 - successful
    400 - not a directory (if the ‘subfile’ argument was used)
    404 - file doesn’t exist
.PARAMETER itemPath
    Folder or file to delete share from
.PARAMETER shareID
    Share ID to delete
.EXAMPLE
    delete-NCuserShare -itemPath "Klassen/FISI23D" -shareID 123
#>
function delete-NCuserShare {
    Param
    (
        # Folder or file to be shared
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
                [String]$itemPath, # without Base URI, e.g. FISI21F, NOT: /Klassen/SJ22-23/FISI21F
        # Nextcloud User ID
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
                [String]$shareID
    )
    Begin{
        $funcName = $MyInvocation.InvocationName # wer bin ich?
        $adminuser=(get-LoginCreds -userKey "NCAdminUser" -passKey "NCadminPass" -passFileKey "NCpassFile").UserName
        $apppass= ConvertFrom-SecureString -SecureString (get-LoginCreds -userKey "NCAdminUser" -passKey "NCadminPass" -passFileKey "NCpassFile").Password -AsPlainText

        $headersDav = @{
            "Authorization" = "Basic $([Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("${adminuser}:${apppass}"))))";
        }
        $headersOcs = @{
            "OCS-APIRequest" = "true";
            "Authorization" = "Basic $([Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("${adminuser}:${apppass}"))))";
        }
    }
    Process {
        $error.clear()
        if (!($itemPath.StartsWith("/"))){
            $itemPath="/"+$itemPath
        }
        $uri=$global:ncParams['NCuriDav']+$itemPath
        # Folder/ File exists?
        $folderexists=test-NCpath -Uri $uri

        if ($folderexists){
            $uri= $global:ncParams['NCuriOcsShares'] + '/' + $shareID
            Try {
                 $inv=Invoke-WebRequest -uri $uri -headers $headersOcs -Method 'DELETE'
                 write-msg -msg  "$funcName : deleting user share: $shareID in folder: $itemPath" -path_prot $global:ncParams['allgLogfile']| Out-Null
            }
            catch {
                write-msg -msg  "$funcName : error in Invoke-Webrequest: $uri" -path_prot $global:ncParams['allgLogfile']| Out-Null
            } 
        }
    }
}
# ************************************** end delete-NCuserShare ************************************ #


# ********** Create hashtable of teacher initials vs email and Nextcloud User ID set-NCuserShare ******** #

# ************************** new-NCuserIDlist ******************************************* #
<#
.SYNOPSIS
    Create a list of Nextcloud User IDs from Nextcloud
.DESCRIPTION
    Create a list of Nextcloud User IDs from Nextcloud. The list is a hashtable with the 
    teacher initials as key and the Nextcloud User ID as value. If the teacher initials are 
    not found in the BBS-Planung, the email address is used as key.
    Teacher initials are stored in the BBS-Planung. We use the backup 
    directory of BBS-Planung to avoid the need of a database connection since that doesn't work 
    with Powershell 7 (DB BBS-Planung is 32 bit only)
.PARAMETER
    None
.EXAMPLE
    new-NCuserIDlist
#>
function new-NCuserIDlist {
    Param
    (
 
    )
    Begin{
        $adminuser=(get-LoginCreds -userKey "NCAdminUser" -passKey "NCadminPass" -passFileKey "NCpassFile").UserName
        $apppass= ConvertFrom-SecureString -SecureString (get-LoginCreds -userKey "NCAdminUser" -passKey "NCadminPass" -passFileKey "NCpassFile").Password -AsPlainText
        $NCuriOcsUsers=$global:ncParams['NCuriOcsUsers']
     
        $headersOcs = @{
            "OCS-APIRequest" = "true";
            "Authorization" = "Basic $([Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("${adminuser}:${apppass}"))))";
        }
        # Get all User IDs
        $userIDs= [xml](Invoke-WebRequest -uri $NCuriOcsUsers -headers $headersOcs -Method 'GET').content

        # Get Teacher initials from BBS-Planung
        # unfortunately this doesn't work with Powershell 7, so use the none DB option in get-BpTeachers                   
        $bpTeachersRaw = get-BpTeachers -useDB $false -bpBackupRootDir $global:NCparams['BPBackupRootDir']

        $bpTeachers=@{}
        # key is email, data is initial
        foreach ($t in $bpTeachersRaw){
            $bpTeachers[$t.'email']=$t.KÜRZEL # key is unfortunately "KÜRZEL"
        }
    }

    Process {
        $error.clear()
        $userEmail_ID=@{}
        foreach ($id in $userids.ocs.data.users.element){
            # iterate all users IDs
            $uri = "$($global:NCparams['NCuriOcsUsers'])/$id"
            Try{            
                $userprops=[xml](Invoke-WebRequest -Uri $uri -Method 'GET' -headers $headersOcs).content
                Try {
                    # E-Mail address from Verwaltungsnetz exists in BBS-Planung
                    $initials=$bpTeachers[$userprops.ocs.data.email]
                }
                catch{
                    # Email address not stored in BBS-Planung, leave with original nextcloud email
                    $initials=$userprops.ocs.data.email
                }
                $userEmail_ID.($initials) = $id
            }
            catch{
                # User doesn't exist
                
                $error.clear()
            }
        }
        return $userEmail_ID
    }
} 
# ************************** end new-NCuserIDlist ********************************** #
# ************************** test-NCpath ******************************************* #
<#
.SYNOPSIS
    Test if a file or folder exists in Nextcloud
.DESCRIPTION
    Test if a file or folder exists in Nextcloud. The function returns $true if the file or folder 
    exists, otherwise $false.
.PARAMETER uri
    Nextcloud Base URI + Folder [+ File ] Name
.EXAMPLE
    test-NCpath -uri "/Klassen/FISI23A"
#>
function test-NCpath {    
    Param
    (
        # Nextcloud Base URI + Folder [+ File ] Name
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
                [String]$uri
    )
    Begin {
        $funcName = $MyInvocation.InvocationName # wer bin ich?
        $adminuser=(get-LoginCreds -userKey "NCAdminUser" -passKey "NCadminPass" -passFileKey "NCpassFile").UserName
        $apppass= ConvertFrom-SecureString -SecureString (get-LoginCreds -userKey "NCAdminUser" -passKey "NCadminPass" -passFileKey "NCpassFile").Password -AsPlainText

        $headers = @{ 
            "Authorization" = "Basic $([Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("${adminuser}:${apppass}"))))"
        }        
    }
    Process {
        $error.clear()        
        # File schon vorhanden?
        Try {
            # -customMethod Parameter works with Powershell 7.1 and higher only !!!!!
            $inv=Invoke-WebRequest -Uri $uri -customMethod 'PROPFIND' -headers $headers
            $uriexists=$true            
        }
        catch {
            # File doesn't exist
            $uriexists=$false
            write-msg -msg  "$funcName : Error with Invoke-Webrequest: $uri" -path_prot $global:ncParams['allgLogfile']| Out-Null
            $error.clear()
        }
        return $uriexists
    }
}
# ************************** end test-NCpath ********************************** #
# ************************** upload-NCfile ******************************************* #
<#
.SYNOPSIS
    Upload a file to Nextcloud
.DESCRIPTION
    Upload a file to Nextcloud. The function returns $true if the file was uploaded successfully, 
    otherwise $false.
.PARAMETER sourceFileUri
    Sourcefile URI in local file system
.PARAMETER destRootFolder
    Destination Rootfolder in Nextcloud (e.g. /Klassen/FISI23A)
    DAV-baseaddress is fixed in this module because it's technically a concern of the Nextcloud instance,
    not the one of the calling script
.PARAMETER destFile
    Destination Filename in Nextcloud (e.g. myDocument.txt)
.PARAMETER overwrite
    $true is Nextcloud default, but for security it's set here to $false by default
.EXAMPLE
    upload-NCfile -sourceFileUri "c:\temp\myDocument.txt" -destRootFolder "/Klassen/FISI23A" -destFile "myDocument.txt"
#>
function upload-NCfile {
    Param
    (
        # Sourcefile URI in local file system
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
                [String]$sourceFileUri, 
        # Destination Rootfolder in Nextcloud (e.g. /Klassen/FISI23A)
        # DAV-baseaddress is fixed in this module because it's technically a concern of the Nextcloud instance,
        # not the one of the calling script
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
                [String]$destRootFolder,
        # Destination Filename in Nextcloud (e.g. myDocument.txt)
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
                [String]$destFile,
        # $true is Nextcloud default, but for security it's set here to $false by default
        [Parameter(Mandatory=$false,
                ValueFromPipelineByPropertyName=$true,
                Position=3)]
             [Boolean]$overwrite=$false
    )
    Begin{
        $funcName = $MyInvocation.InvocationName
        $adminuser=(get-LoginCreds -userKey "NCAdminUser" -passKey "NCadminPass" -passFileKey "NCpassFile").UserName
        $apppass= ConvertFrom-SecureString -SecureString (get-LoginCreds -userKey "NCAdminUser" -passKey "NCadminPass" -passFileKey "NCpassFile").Password -AsPlainText

        $headers = @{ 
            "Authorization" = "Basic $([Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("${adminuser}:${apppass}"))))"
            "Content-Type" = "text/csv"
        }
        $error.clear()
    }
    Process {
        # Build complete filename
        $destFile=$destFile.Replace("/","")
        if ($destRootFolder -eq "/"){
            $uri=$global:ncParams['NCuriDav']+$destRootFolder+$destFile
        }
        else{
            $destRootFolder=$destRootFolder.TrimStart("/")
            $destRootFolder=$destRootFolder.TrimEnd("/")
            $uri=$global:ncParams['NCuriDav']+"/"+$destRootFolder+"/"+$destFile
        }
        # File already exists?
        if($overwrite){
            $fileexists=$false
        }
        else{
            $fileexists=test-NCpath -Uri $uri
        }
        
        if (!$fileexists){
            Try {
                $body=$(Get-Content $sourceFileUri -raw)
                $inv=Invoke-WebRequest -Uri $uri -Method 'PUT' -headers $headers -body $body
             }
            catch {
                write-msg -msg  "$funcName : Error with Invoke-Webrequest: $uri" -path_prot $global:ncParams['allgLogfile']| Out-Null
                $Error
            } 
        }  

    }

} # end upload-nextCloudFile
# ************************************** end upload-nextCloudFile ************************************ #
# ************************************** new-NCfolders ************************************'
<#
.SYNOPSIS
    Create a folder structure in Nextcloud for each class
.DESCRIPTION
    Create a folder structure in Nextcloud for each class. The structure is as follows:
    - Class as headline
        - Enrollment documents incl. signature lists
        - Company and student lists
        - Certificates with subfolders 1st, 2nd, 3rd year
            and there subfolders Winter/Summer
        - Class meetings
        - Excuses and exemptions
    The function reads the class:teacher hashtable from Untis or file and 
    creates a list of teacher initials and Nextcloud User ID.
.EXAMPLE
    new-NCfolders
#>
function new-NCfolders{
    # ******************************** main *********************************************** #
    # Struktur Klassenordner Nextcloud:
    #   Klasse als Überschrift 
    #       Einschulungsunterlagen incl. Unterschriftenlisten 
    #       Betriebsliste mit E-Mail-Adressen 
    #       Zeugnisse mit Unterordnern 1. AJ, 2. AJ, 3. AJ 
    #            und dort Unterordner Winter/Sommer 
    #       Klassenbesprechungen 
    #       Entschuldigungen-Freistellungen 
    Begin{
        $funcName = $MyInvocation.InvocationName # wer bin ich?
        $subfolderURIs = @()
        $subfolderURIs += "Einschulungsunterlagen Unterschriftenlisten"
        $subfolderURIs += "Betriebs- und Lernendenlisten"
        $subfolderURIs += "Zeugnis"
        $subfolderURIs += "Zeugnis"+"/"+"1. AJ"
        $subfolderURIs += "Zeugnis"+"/"+"1. AJ"+"/"+"Winter"
        $subfolderURIs += "Zeugnis"+"/"+"1. AJ"+"/"+"Sommer"
        $subfolderURIs += "Zeugnis"+"/"+"2. AJ"
        $subfolderURIs += "Zeugnis"+"/"+"2. AJ"+"/"+"Winter"
        $subfolderURIs += "Zeugnis"+"/"+"2. AJ"+"/"+"Sommer"
        $subfolderURIs += "Zeugnis"+"/"+"3. AJ"
        $subfolderURIs += "Zeugnis"+"/"+"3. AJ"+"/"+"Winter"
        $subfolderURIs += "Zeugnis"+"/"+"3. AJ"+"/"+"Sommer"
        $subfolderURIs += "Klassenbesprechungen"
        $subfolderURIs += "Entschuldigungen Freistellungen"

        $rootfoldername=$global:ncParams['NCrootFolderName']
        write-msg -msg  "$funcName : Read hashtable classes:Teachers from Untis or file" -path_prot $global:ncParams['allgLogfile']| Out-Null
        $hashClassesTeachers=@{}
        # get credentials for Untis
        $WUcreds=get-LoginCreds -userKey "WUuser" -passKey "WUpass" -passFileKey "WUpassFile"
    
        $hashClassesTeachers=get-untisClassTeacherTeams -checkHashlistClassesTeachers $true -WUlocationClassTeachers $global:ncParams['WUlocationClassTeachers'] -WUclassesTeachersDelimiter $global:ncParams['WUclassesTeachersDelimiter'] -WUcreds $WUcreds 
        # Read hashtable classes:Teachers from Untis or file
        write-msg -msg  "$funcName : Creating list of teacher initials and Nextcloud User ID" -path_prot $global:ncParams['allgLogfile']| Out-Null
        $userInitial_NCid=new-NCuserIDlist  # List of teacher initials and Nextcloud User ID       
    }
    Process{
        foreach ($class in $hashClassesTeachers.Keys){
            # teachers of the class
            $teachers = ($hashClassesTeachers[$class] + ',' + $global:ncParams['NClistOfAdditionalSharers']).split(",")
            
            # if it doesn't already exists create New Class Folder
            if ($rootfoldername -eq "/"){
                $itempath=$rootfoldername+$class         
            }
            else{
                $rootfoldername=$rootfoldername.TrimStart("/")
                $rootfoldername=$rootfoldername.TrimEnd("/")
                $itempath="/"+$rootfoldername+"/"+$class
            }
            $uri=$global:ncParams['NCuriDav']+$itempath

            $fileexists=test-NCpath -uri $uri 
            if (!$fileexists) {
                new-NCfolder -rootFolderName $rootFolderName -newFolderName $class
            }
            else{
                # compare and remove former shares/ priviliges which are no longer valid
                $oldUserShares=get-NCuserShares -itemPath $itempath
                foreach ($oldUserShare in $oldUserShares.GetEnumerator()){
                    $valid=$false
                    foreach ($teacher in $teachers){
                        if (!$valid -and $oldUserShare.key -eq $userInitial_NCid[$teacher]){$valid=$true}
                    }
                    if (!$valid){
                        # old usershare is no longer in new teacher list: delete-NCuserShare
                        delete-NCuserShare -itemPath $itempath -shareID $oldUserShare.value
                    } 
                }
            }        
            # set user privileges
            foreach ($teacher in $teachers){
                Try{
                    # if $teacher is not in $hashClassesTeachers this will throw an error 
                    # Untis returns non valid initials every now and then e.g. "---"
                    set-NCuserShare -itemPath $itemPath -userID $userInitial_NCid[$teacher]
                }
                catch{
                    # nothing to do, leave that non valid initial out and jump to next entry
                    write-msg -msg  "$funcName : initial $teacher not valid, class: $class" -path_prot $global:ncParams['allgLogfile']| Out-Null
                }
            }
            # Add additional subfolders for the new classfolders
            if (!$fileexists) {
                foreach ($folder in $subfolderURIs){            
                    # create new Subfolder
                    write-msg -msg  "$funcName : creating new subfolder: $folder" -path_prot $global:ncParams['allgLogfile']| Out-Null
                    new-NCfolder -rootFolderName $itempath -newFolderName $folder 
                }
            }
        }
    } 
}
# end new-NCfolders
# ************************************** end new-NCfolders ************************************ #
# ************************************** is-Under18 ************************************ #
<#
.Synopsis
   Prüft, ob ein SoS minderjährig ist
.DESCRIPTION
   Prüft, ob ein SoS minderjährig ist
.PARAMETER dateOfBirth
    Geburtsdatum des SoS im Format dd.MM.yyyy
.EXAMPLE
   is-Under18 -dateOfBirth "28.04.2004" 
#>
function is-Under18
{
   [CmdletBinding()]
   Param 
   (
      [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
      [String]$dateOfBirth # dd.MM.yyyy Format wie aus get-BPPupils
   )
   Begin{
      $doB = [datetime]::parseexact($dateOfBirth, 'MM/dd/yyyy HH:mm:ss',$null)
      $now = Get-Date
      $dif = $now - $doB
      $years = [Math]::Truncate($($now - $doB).Days / 365)
      if ($years -lt 18){return $true} else {return $false} 
   }
}
# ************************************** end is-Under18 ************************************ #

<# ************************************** new-classList ************************************ #
.Synopsis
   Erstellt eine Klassenliste mit Daten aus BBS-Planung und Active Directory des Schulnetzes

.DESCRIPTION
    Die Funktion new-classList ist dafür konzipiert, 
    eine Liste von Schülerdaten basierend auf verschiedenen Eingabeparametern 
    zu erstellen. Diese Funktion nimmt Daten von Schülern, Unternehmen und 
    Ausbildern aus BBS-Planung entgegen und verarbeitet diese, 
    um eine detaillierte Klassenliste zu erstellen. 
    Hier ist eine Schritt-für-Schritt-Erklärung der Funktionsweise:
    Im Begin-Block werden Kommentare verwendet, um die Struktur der Eingabedaten 
    zu beschreiben. Dies umfasst Informationen wie Klassenname, 
    Schülerdaten (z.B. Name, Geburtsdatum, Adresse), 
    Unternehmensdaten (z.B. Name, Adresse) und 
    Ausbilderdaten (z.B. Name, E-Mail, Telefon).
    Im Process-Block erfolgt die eigentliche Verarbeitung:
    Initialisierung der Klassenliste: Eine leere Liste wird erstellt, um die 
    verarbeiteten Schülerdaten aufzunehmen.
    Selektion der Schüler der aktuellen Klasse: Durch Filterung der 
    $bpStudents-Liste werden nur die Schüler der spezifizierten Klasse ($class) 
    ausgewählt.
    Durchlaufen der Schülerliste: Für jeden Schüler in der gefilterten Liste werden 
    folgende Schritte durchgeführt:
    Ein neues Objekt für den Schüler wird erstellt, mit vordefinierten Eigenschaften.
    Überprüfung, ob der Schüler minderjährig ist, basierend auf dem Geburtsdatum.
    Zuweisung der Schülerdaten zu den entsprechenden Eigenschaften des neuen Objekts.
    Ermittlung und Zuweisung der Ausbilder- und Unternehmensdaten, falls vorhanden.
    Das neue Schülerobjekt wird der Klassenliste hinzugefügt.
    Sortierung der Klassenliste: Die fertige Liste wird nach Nachnamen (und Vornamen) der Schüler sortiert.
    Rückgabewert
    Die sortierte Klassenliste wird als Ergebnis der Funktion zurückgegeben.
.PARAMETER class
    Der Name der Klasse, für die die Liste erstellt wird.
.PARAMETER bpStudents
    Eine Liste von Schülerdaten.
.PARAMETER bpCompanies 
    Eine Liste von Unternehmensdaten.
.PARAMETER bpInstructors
    Eine Liste von Ausbilderdaten.
.PARAMETER adStudents  
    Eine Liste von Schülerdaten aus einem Active Directory, speziell für E-Mail-Adressen.
.EXAMPLE
    new-classList -class "FISI20A" -bpStudents $bpStudents -bpCompanies $bpCompanies -bpInstructors $bpInstructors -adStudents $adStudents
#>
function new-classList
{

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$class,
  
        [Parameter(Mandatory=$true)]
        [System.Collections.ArrayList]$bpStudents,
  
        [Parameter(Mandatory=$true)]
        [System.Collections.ArrayList]$bpCompanies,
  
        [Parameter(Mandatory=$true)]
        [System.Collections.ArrayList]$bpInstructors,
  
        [Parameter(Mandatory=$true)]
        [System.Collections.ArrayList]$adStudents
      )

    Begin {     
      # $bpClasses
         # KNAME: Klassenname
         # ID_LEHRER: Lehrkraftkürzel

      # $bpStudents  
         # BBSID        : 376
         # NNAME        : Müller
         # VNAME        : Benjamin
         # GEBDAT       : 02.02.2002 00:00:00
         # GEBORT       : Kneipendorf
         # STR          : Auguststraße 42
         # PLZ          : 34567
         # ORT          : Kneipendorf
         # TEL          :
         # TEL_HANDY    : 0123 4567890
         # FAX          : EmployeeID
         # EMAIL        : benjamin.mueller@gmx.de
         # GESCHLECHT   : 1
         # KL_NAME      : FISI20A
         # BETRIEB_NR   : 1047 (weist auf get-BPInstructors.betrieb_nr und get-BPCompanies.betrieb_nr)
         # ID_AUSBILDER :
         # E_ANREDE     :
         # E_NNAME      : Müller
         # E_VNAME      : Mama
         # E_STR        : Auguststraße 42
         # E_PLZ        : 34567
         # E_ORT        : Kneipendorf
         # E_TEL        :
         # E_FAX        :
         # E_EMAIL      :
      
      # $bpCompanies
         # NAME       : ABC Solutions GmbH
         # PLZ        : 30111
         # ORT        : Hannover
         # STRASSE    : Bergstr. 20
         # NR         : 
         # ID         : 1896
         # BETRIEB_NR : 9

      # $bpInstructors
         # BETRIEB_NR : 444  
         # ID_BETRIEB : 1896 (weist auf get-BPCompanies.
         # NNAME      : Herr Goethe
         # EMAIL      : wolfgang@goethe.com
         # TELEFON    : 0500 54 22 000
         # FAX        : 0500 54 22 001
         # NNAME2     :
         # EMAIL2     :
         # TELEFON2   :

   }
   Process {      
      # Neues Klassenformular anlegen
      $classList = @() 
   
      # SuS der aktuellen Klasse selektieren
      $bpStudentsOfTheClass = $bpStudents|Where-Object {$_.KL_NAME -eq $class}
      foreach ($bpStudent in $bpStudentsOfTheClass){
        $newStudent = "" | Select-Object -Property "NNAME","VNAME","KLASSE","EMAIL","GEBDAT","MINDERJ","AUSNAME","AUSEMAIL","AUSTEL","AUSBETR","AUSSTR","AUSPLZ","AUSORT","ENNAME","EVNAME","EEMAIL","ETEL"
        # Für jeden SoS Daten eintragen
        try{
            $isUnder18 = is-Under18 ($bpStudent.GEBDAT)
            $newStudent.GEBDAT = get-date -Date $bpStudent.GEBDAT -Format "dd.MM.yyyy"
            $newStudent.MINDERJ = if($isUnder18){$global:NCparams['NCtextMinderjaehrig']} else {$global:NCparams['NCtextErwachsen']}
        }
        catch {$isUnder18 = $false} # Geburtsdatum in BBS-Planung leer oder falsches Format

        $newStudent.NNAME = $bpStudent.NNAME
        $newStudent.VNAME = $bpStudent.VNAME
        $newStudent.KLASSE = $bpStudent.KL_NAME            
        $newStudent.ENNAME = if($isUnder18){$bpStudent.E_NNAME} else {""}
        $newStudent.EVNAME = if($isUnder18){$bpStudent.E_VNAME} else {""}
        $newStudent.EEMAIL = if($isUnder18){$bpStudent.E_EMAIL} else {""}
        $newStudent.ETEL = if($isUnder18){$bpStudent.E_TEL} else {""}
        $newStudent.EMAIL = ($adStudents|Where-Object{$_.EmployeeID -eq $bpStudent.FAX}).Mail

        # Ausbilder/ Betrieb ermitteln und eintragen
        if ($bpStudent.BETRIEB_NR -ne ""){
            $instructor = ($bpInstructors|where-Object{$_.BETRIEB_NR -eq $bpStudent.BETRIEB_NR})
            $company = ($bpCompanies|where-Object{$_.BETRIEB_NR -eq $bpStudent.BETRIEB_NR})
            $newStudent.AUSNAME = $instructor.NNAME
            $newStudent.AUSEMAIL = $instructor.EMAIL
            $newStudent.AUSTEL = $instructor.TELEFON
            $newStudent.AUSBETR = $company.NAME
            $newStudent.AUSSTR = $company.STRASSE
            $newStudent.AUSPLZ = $company.PLZ
            $newStudent.AUSORT = $company.ORT
        }
        else{
            $newStudent.AUSNAME = ""
            $newStudent.AUSEMAIL = ""
            $newStudent.AUSTEL = ""
            $newStudent.AUSBETR = ""
            $newStudent.AUSSTR = ""
            $newStudent.AUSPLZ = ""
            $newStudent.AUSORT = ""
        } # Ende Daten eines SoS eintragen

        $classList += $newStudent
      } # Ende Daten aller SoS einer Klasse eintragen
      # Klassenliste nach Nachnamen sortieren


      ### ---- Klassenliste mit Lernenden gefüllt ----####
      return ($classList|sort-object -Property @{Expression="NNAME"}, @{Expression="VNAME"})
   } # Ende Daten einer Klasse eintragen
 
}
# ************************************** end new-classList ************************************ #
# ************************************** new-NCclassLists ************************************ #
<#
.Synopsis
   Erstellt csv-Listen, ähnlich wie Klassenlisten mit E-mail in BBS Planung und legt sie in der Nextcloudstruktur der Klasse ab
.DESCRIPTION
   Erstellt csv-Listen, ähnlich wie Klassenlisten mit E-Mail in BBS Planung 
   und legt sie in der Nextcloudstruktur der Klasse ab
   Sollte eine Datei ($global:ncParams['LDAPsusFilePath'] mit SuS-LDAP-Daten vorhanden sein,
   wird diese genutzt anstelle einer LDAP-Abfrage
.EXAMPLE
   new-NCclassLists
#>
function new-NCclassLists{
   [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$false)] [boolean] $sendEMailToTeachers=$false
    )

    Begin
    {
      #
      # Das Skript läuft auf dem Terminalserver im Verwaltungsnetz, da dort die Anbindung an BBS-Planung möglich ist
      $funcName = $MyInvocation.InvocationName
      
      $pathOldLists = $global:NCparams['NCpathOldClassLists']
      $pathNewLists = $global:NCparams['NCpathNewClassLists']
      $csvDelimiter = $global:NCparams['allgCsvDelimiter']

      # Alle Daten besorgen
      $timeStamp = write-msg -msg  "$funcName : Lese Klassenliste ein..." -path_prot $global:ncParams['allgLogfile']
      $bpClasses = get-BPcourses -useDB $false -bpBackupRootDir $global:NCparams['BPBackupRootDir']
      write-msg -msg  "$funcName : Klassenliste eingelesen" -time $timeStamp -path_prot $global:ncParams['allgLogfile']

      $timeStamp = write-msg -msg  ("$funcName : Lese Schülerliste ein...") -path_prot $global:ncParams['allgLogfile']
      $bpStudents = get-BPPupils -useDB $false -bpBackupRootDir $global:NCparams['BPBackupRootDir']
      write-msg -msg  ("$funcName : Schülerliste eingelesen") -time $timeStamp

      $timeStamp = write-msg -msg  ("$funcName : Lese Betriebsliste ein...")
      $bpCompanies = Get-BPCompanies -useDB $false -bpBackupRootDir $global:NCparams['BPBackupRootDir']
      write-msg -msg  ("$funcName : Betriebsliste eingelesen") -time $timeStamp -path_prot $global:ncParams['allgLogfile']

      $timeStamp = write-msg -msg  ("$funcName : Lese Lehrkräfteliste ein...")
      $bpInstructors = Get-BPinstructors -useDB $false -bpBackupRootDir $global:NCparams['BPBackupRootDir']
      write-msg -msg  ("$funcName : Lehrkräfteliste eingelesen") -time $timeStamp -path_prot $global:ncParams['allgLogfile']

      # Get credentials for LDAP access school network 
      $ldapCreds=(get-LoginCreds -userKey "LDAPuserName" -passKey "LDAPuserPass" -passFileKey "LDAPuserCredsFile")

      
      # Daten der Lernenden aus AD lesen
      if((Test-Path $global:NCparams['LDAPsusFilePath']) -and ((Get-Item $($global:NCparams['LDAPsusFilePath'])).LastWriteTime.Date -eq (Get-Date).Date)){
        # Daten aus vorheriger Abfrage auslesen, falls diese vorhanden sind UND TAGESAKTUELL (geht schneller) 
        write-msg -msg  "$funcname : Lese LDAP-Daten der Lernenden aus Datei $($global:NCparams['LDAPsusFilePath']) aus..." -path_prot $global:ncParams['allgLogfile']| Out-Null
        $adStudents=Import-csv -Path $global:NCparams['LDAPsusFilePath'] -Encoding utf8 -Delimiter $global:NCparams['allgCsvDelimiter']
      }
      else { 
         # Keine gespeicherten Daten vorhanden
         Try{
            $timeStamp = write-msg -msg  "$funcname : Hole LDAP-Daten der Lernenden von $($global:NCparams['LDAPmm-bbsURI'])..." -path_prot $global:ncParams['allgLogfile']
            $adStudents=Get-ADUser -Server $global:NCparams['LDAPmm-bbsURI'] -Credential $ldapCreds -Properties EmployeeID,Surname,GivenName,Mail,DistinguishedName -Filter {(Name -like "*")} -SearchBase "OU=Schueler,DC=int,DC=mm-bbs,DC=de"
            write-msg -msg  "$funcname : LDAP-Daten der Lernenden geholt" -time $timeStamp -path_prot $global:ncParams['allgLogfile']

            # EmployeeID ist das Attribut Faxnummer, also unser Primärschlüssel in BBS-Planung etc.
            # für nächsten Durchlauf speichern 
            $adStudents|export-csv -Path $global:NCparams['LDAPsusFilePath'] -Encoding UTF8 -NoTypeInformation -Delimiter $global:NCparams['allgCsvDelimiter']            
            write-msg -msg  "$funcname : LDAP-Daten der Lernenden in Datei $($global:NCparams['LDAPsusFilePath']) gespeichert" -path_prot $global:ncParams['allgLogfile']| Out-Null
         }
         catch{
            write-msg -msg  "$funcName : Error access to LDAP server $($error)" -path_prot $global:ncParams['allgLogfile']| Out-Null
            $error.clear()
         }
      }

      # Daten der Lehrkräfte aus AD lesen
      if((Test-Path $global:NCparams['LDAPlulFilePath']) -and ((Get-Item $($global:NCparams['LDAPlulFilePath'])).LastWriteTime.Date -eq (Get-Date).Date)){
        # Daten aus vorheriger Abfrage auslesen, falls diese vorhanden sind UND TAGESAKTUELL (geht schneller) 
        write-msg -msg  "$funcname : Lese LDAP-Daten der Lehrkräfte aus Datei $($global:NCparams['LDAPlulFilePath']) aus..." -path_prot $global:ncParams['allgLogfile']| Out-Null
        $adTeachers=Import-csv -Path $global:NCparams['LDAPlulFilePath'] -Encoding utf8 -Delimiter $global:NCparams['allgCsvDelimiter']
      }
      else { 
         # Keine gespeicherten Daten vorhanden
         Try{
            $timeStamp = write-msg -msg  "$funcname : Hole LDAP-Daten der Lehrkräfte von $($global:NCparams['LDAPmm-bbsURI'])..." -path_prot $global:ncParams['allgLogfile']
            $adTeachers=Get-ADUser -Server $global:NCparams['LDAPmm-bbsURI'] -Credential $ldapCreds -Properties Initials,Surname,GivenName,Mail,DistinguishedName -Filter {(Name -like "*")} -SearchBase "OU=Lehrer,DC=int,DC=mm-bbs,DC=de"
            # Initials ist das Lehrkraftkürzel, also unser Primärschlüssel in BBS-Planung etc.
            # für nächsten Durchlauf speichern 
            $adTeachers|export-csv -Path $global:NCparams['LDAPlulFilePath'] -Encoding UTF8 -NoTypeInformation -Delimiter $global:NCparams['allgCsvDelimiter']            
            write-msg -msg  "$funcname : LDAP-Daten der Lehrkräfte in Datei $($global:NCparams['LDAPlulFilePath']) gespeichert" -time $timeStamp -path_prot $global:ncParams['allgLogfile'] 
         }
         catch{
            write-msg -msg  "$funcName : Error access to LDAP server" -path_prot $global:ncParams['allgLogfile']| Out-Null
            $error.clear()
         }
      }
      # Bei Bedarf Klassenordner anlegen
      if (!(test-path $pathOldLists)){New-Item -Path $pathOldLists -ItemType Directory}
      if (!(test-path $pathNewLists)){New-Item -Path $pathNewLists -ItemType Directory}
   }
   Process{
      foreach ( $class in $bpClasses){
         write-msg -msg  ("$funcName : Erzeuge Klassenliste $($class.KNAME)...") -path_prot $global:ncParams['allgLogfile']| Out-Null

         $classList = new-classList -class $class.KNAME -bpStudents $bpStudents -bpCompanies $bpCompanies -bpInstructors $bpInstructors -adStudents $adStudents

         # csv Datei schreiben
         $classList|export-csv -path "$pathNewLists\$($class.KNAME).csv" -encoding UTF8 -delimiter $csvDelimiter -noTypeInformation

         $replaceClassList = $false
         # Falls alte Klassenliste vorhanden, prüfen, ob neue Liste Änderungen aufweist
         if (test-path "$pathOldLists\$($class.KNAME).csv"){
            # alte Liste vorhanden
            $oldListContent = Get-Content -Path "$pathOldLists\$($class.KNAME).csv"
            $newListContent = Get-Content -Path "$pathNewLists\$($class.KNAME).csv"
            # Vergleichen nur, wenn Länge gleich ist
            if ($oldListContent.count -eq $newListContent.count){
                $len=$newListContent.count
                # Inhalt zeilenweise vergleichen
                for ($idx=0;($idx -lt $len) -and (!$replaceClassList); $idx+=1){
                    if ($oldListContent[$idx] -ne $newListContent[$idx]){
                       $replaceClassList = $true # aktuelle Zeilen in beiden Listen unterschiedlich
                    }
                }
            }
            else {$replaceClassList = $true} # Länge der alten und neuen Liste unterschiedlich
           
         }
         else {$replaceClassList = $true} # Alte Klassenliste nicht vorhanden, also ganz neu anlegen

         if ($replaceClassList){
            # Liste ersetzen, neue Liste zu alten Listen hinzufügen/ alte Liste überschreiben
            copy-Item -path "$pathNewLists\$($class.KNAME).csv" -destination "$pathOldLists\$($class.KNAME).csv" -force

            # Neue Liste in Nextcloud speichern
            upload-NCfile -sourceFileUri "$pathNewLists\$($class.KNAME).csv" -destRootFolder "$($global:NCparams['NCrootFolderName'])/$($class.KNAME)/$($global:NCParams['NCsusListenFolderName'])" -destFile "$($class.KNAME).csv" -overwrite $true
            write-msg -msg  "$funcname : $($class.KNAME).csv in Nextcloud geladen" -path_prot $global:ncParams['allgLogfile']| Out-Null

            if ($sendEMailToTeachers){
                # Pushnachricht Klassenlehrkräfte (evtl. mit detaillierten Änderungen, dann oben compare-object verwenden anstatt hashvergleich)
                # Get all teachers of the class, Parameter true sorgt für das Lesen einer gespeicherten, tagesaktuellen Version der Hashtabelle, falls vorhanden (geht schneller)
                
                # get credentials for Untis
                $WUcreds=get-LoginCreds -userKey "WUuser" -passKey "WUpass" -passFileKey "WUpassFile"          
                $hashClassesTeachers=get-untisClassTeacherTeams -checkHashlistClassesTeachers $true -WUlocationClassTeachers $global:ncParams['WUlocationClassTeachers'] -WUclassesTeachersDelimiter $global:ncParams['WUclassesTeachersDelimiter'] -WUcreds $WUcreds 
                # 
                # Lehrkräfte der aktuellen Klasse ermitteln
                $classTeachers = @()
                $classTeachers = ($hashClassesTeachers[$class.KNAME]).split($global:ncParams.WUclassesTeachersDelimiter)

                # E-Mailadressen der LuL ermitteln, Lehrkäftedaten aus AD stehen in $adTeachers
                $classTeachersEmail = @()
                foreach ($teacher in $classTeachers){
                    $mail=""|select-object -Property email, initial, GivenName, Name
                    $mail.email = ($adTeachers|Where-Object{$_.Initials -eq $teacher}).Mail
                    $mail.initial = $teacher
                    $mail.GivenName = ($adTeachers|Where-Object{$_.Initials -eq $teacher}).GivenName
                    $mail.Name = ($adTeachers|Where-Object{$_.Initials -eq $teacher}).Name

                    if ($mail.email -ne $null) {$classTeachersEmail += $mail} 
                }

                # Get credentials for EMAIL access 
                $EMAILpw = ConvertFrom-SecureString -SecureString (get-LoginCreds -userKey "EMAILadminUser" -passKey "EMAILadminPass" -passFileKey "EMAILpassFile").Password -AsPlainText
                $timeStamp = get-date
                write-msg -msg  "$funcname : Schreibe E-Mails an Lehrkräfte ..." -path_prot $global:ncParams['allgLogfile']| Out-Null
                $emailcreds = get-LoginCreds -userKey "EMAILadminUser" -passKey "EMAILadminPass" -passFileKey "EMAILpassFile"
                $emailbody=""
                foreach ($to in $classTeachersEmail) {
                    $emailSubject = $global:ncParams.EMAILsubject
                    $emailSubject=$emailSubject.Replace("<Klasse>", $class.KNAME)

                    $emailbody=$null
                    $emailbody=(Get-Content -path $global:ncParams.EMAILbodyFile) -join "`n"
                    $emailbody=$emailbody.Replace("<Vorname>",$to.GivenName)
                    $emailbody=$emailbody.Replace("<Nachname>",$to.Name)
                    $emailbody=$emailbody.Replace("<Klasse>",$class.KNAME)
                    $recipient = $to.email
                    $sender = $global:ncparams.EMAILsender

                    Send-MailMessage -Credential $emailcreds -to $recipient -from $sender -SmtpServer $global:ncParams.EMAILserver -Port $global:ncParams.EMAILport -Encoding UTF8 -Subject $emailSubject -body $emailBody -BodyAsHtml
                    
                }
                write-msg -msg  "$funcname : E-Mails an Lehrkräfte der Klasse $($class.KNAME) verschickt!"  -path_prot $global:ncParams['allgLogfile']| Out-Null
            } # Ende E-Mail an Lehrkräfte

         } # Ende Liste ersetzen

      } # Ende mit alle Klassenlisten erstellen
   } # end Process
}
# ************************************** end new-NCclassLists ************************************ #
# ************************************** end nextcloudVWNManager ************************************ #
<#  Alle Funktionen in diesem Modul
get-NCparameters
get-LoginCreds
new-NCfolder
set-NCuserShare
get-NCuserShares
delete-NCuserShare
new-NCuserIDlist
test-NCpath
upload-NCfile
new-NCfolders
is-Under18
new-classList
new-NCclassLists
#>
