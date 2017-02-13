#
# Utility script to create MySql databases required by ACE
#
# Place this .ps1 in the root DATABASE folder in the solution directory.
# Remember to update server/user/password variables
#
# Created By Brian Mitchell
# 2017-2-13
#

[void][system.reflection.Assembly]::LoadWithPartialName("MySql.Data")

# Ask for elevated permissions if required
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

$dbserver = "localhost"
$dbusername = "root"
$dbpassword = "********"

$authschemaname = "ace_auth"
$worldschemaname = "ace_world"
$characterschemaname = "ace_character"

$basescriptpath = ".\Base\"
$authupdatescriptpath = ".\Updates\Authentication\"
$worldupdatescriptpath = ".\Updates\World\"
$characterupdatescriptpath = ".\Updates\Character\"

# Create schemas in MySql
$connStr = "server=" + $dbserver + ";Persist Security Info=false;user id=" + $dbusername + ";pwd=" + $dbpassword + ";"
$conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connStr)

$conn.Open()

$cmd = New-Object MySql.Data.MySqlClient.MySqlCommand
$cmd.Connection  = $conn

# Create schemas
# Drop auth schema
$cmd.CommandText = "DROP DATABASE IF EXISTS " + $authschemaname
$cmd.ExecuteNonQuery()

# Drop world schema
$cmd.CommandText = "DROP DATABASE IF EXISTS " + $worldschemaname
$cmd.ExecuteNonQuery()

# Drop character schema
$cmd.CommandText = "DROP DATABASE IF EXISTS " + $characterschemaname
$cmd.ExecuteNonQuery()

# Create auth schema
$cmd.CommandText = 'CREATE SCHEMA `' + $authschemaname + '`'
$cmd.ExecuteNonQuery()

# Create world schema
$cmd.CommandText = 'CREATE SCHEMA `' + $worldschemaname + '`'
$cmd.ExecuteNonQuery()

# Create character schema
$cmd.CommandText = 'CREATE SCHEMA `' + $characterschemaname + '`'
$cmd.ExecuteNonQuery()

$conn.Close()

# Run data scripts
# Auth
$connStr = "server=" + $dbserver + ";Database=" + $authschemaname + ";Persist Security Info=false;user id=" + $dbusername + ";pwd=" + $dbpassword + ";"
$conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connStr)

$conn.Open()

$sql = (Get-Content -path ($basescriptpath + "AuthenticationBase.sql")) -join "`r`n"

$cmd = New-Object MySql.Data.MySqlClient.MySqlCommand
$cmd.CommandText = $sql
$cmd.Connection  = $conn
$cmd.ExecuteNonQuery()

$updates = Get-ChildItem $authupdatescriptpath -Filter *.sql | Sort-Object

for ($i=0; $i -lt $updates.Count; $i++) {
	$sql = (Get-Content -path ($authupdatescriptpath + $updates[$i])) -join "`r`n"
	$cmd = New-Object MySql.Data.MySqlClient.MySqlCommand
	$cmd.CommandText = $sql
	$cmd.Connection  = $conn
	$cmd.ExecuteNonQuery()
}

$conn.Close()

# World
$connStr = "server=" + $dbserver + ";Database=" + $worldschemaname + ";Persist Security Info=false;user id=" + $dbusername + ";pwd=" + $dbpassword + ";"
$conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connStr)

$conn.Open()

$sql = (Get-Content -path ($basescriptpath + "WorldBase.sql")) -join "`r`n"

$cmd = New-Object MySql.Data.MySqlClient.MySqlCommand
$cmd.CommandText = $sql
$cmd.Connection  = $conn
$cmd.ExecuteNonQuery()

$updates = Get-ChildItem $worldupdatescriptpath -Filter *.sql | Sort-Object

for ($i=0; $i -lt $updates.Count; $i++) {
	$sql = (Get-Content -path ($worldupdatescriptpath + $updates[$i])) -join "`r`n"
	$cmd = New-Object MySql.Data.MySqlClient.MySqlCommand
	$cmd.CommandText = $sql
	$cmd.Connection  = $conn
	$cmd.ExecuteNonQuery()
}

$conn.Close()

# Character
$connStr = "server=" + $dbserver + ";Database=" + $characterschemaname + ";Persist Security Info=false;user id=" + $dbusername + ";pwd=" + $dbpassword + ";"
$conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connStr)

$conn.Open()

$sql = (Get-Content -path ($basescriptpath + "CharacterBase.sql")) -join "`r`n"

$cmd = New-Object MySql.Data.MySqlClient.MySqlCommand
$cmd.CommandText = $sql
$cmd.Connection  = $conn
$cmd.ExecuteNonQuery()

$updates = Get-ChildItem $characterupdatescriptpath -Filter *.sql | Sort-Object

for ($i=0; $i -lt $updates.Count; $i++) {
	$sql = (Get-Content -path ($characterupdatescriptpath + $updates[$i])) -join "`r`n"
	$cmd = New-Object MySql.Data.MySqlClient.MySqlCommand
	$cmd.CommandText = $sql
	$cmd.Connection  = $conn
	$cmd.ExecuteNonQuery()
}

$conn.Close()