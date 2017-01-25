/* Copyright 2015 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
//------------------------------------------------------------------------------

function Component()
{
    // constructor

    var homeDir = installer.value("homeDir");
    var targetDir = installer.value("TargetDir");
    var adminTargetDir = installer.value("AdminTargetDir");

    print("Initial values: os=" + installer.value("os"));
    print("homeDir=" + homeDir);
    print("targetDir=" + targetDir);
    print("adminTargetDir=" + adminTargetDir);

    //--------------------------------------------------------------------------
    // Windows
    //
    // Install to ~/Applications instead of @homeDir@

    if (installer.value("os") === "win") {
        var programFilesDir = installer.environmentVariable("ProgramFiles(x86)");
        var appDataDir = installer.environmentVariable("APPDATA");
        var esriDir = appDataDir + "/ESRI";
        var appsDir = homeDir + "/Applications";
        targetDir = targetDir.replace("@homeDir@", appsDir);
        targetDir = targetDir.replace(homeDir, appsDir);

        // Install under program files if admin

        adminTargetDir = adminTargetDir.replace("@rootDir@", programFilesDir);
        installer.setValue("AdminTargetDir", adminTargetDir);
    }

    //--------------------------------------------------------------------------
    // MacOS
    //
    // Install to ~/Applications instead of @homeDir@

    if (installer.value("os") === "mac") {
        var applicationsDir = homeDir + "/Applications";

        targetDir = targetDir.replace("@homeDir@", applicationsDir);
        targetDir = targetDir.replace(homeDir, applicationsDir);
    }

    //--------------------------------------------------------------------------
    // Linux
    //
    // Install to ~/Applications instead of @homeDir@

    if (installer.value("os") === "x11") {
        var aDir = homeDir + "/Applications";

        targetDir = targetDir.replace("@homeDir@", aDir);
        targetDir = targetDir.replace(homeDir, aDir);
    }

    //--------------------------------------------------------------------------

    installer.setValue("TargetDir", targetDir);

    print("Updated values:-");
    print("targetDir=" + targetDir);
    print("adminTargetDir=" + adminTargetDir);


    // Component selection page
    installer.setDefaultPageVisible(QInstaller.ComponentSelection, false);

    // Start menu selection page
    installer.setDefaultPageVisible(QInstaller.StartMenuSelection, true);
    // installer.setValue("StartMenuDir", "ArcGIS/AppStudio");

    installer.setDefaultPageVisible(QInstaller.TargetDirectory, true);

}

//------------------------------------------------------------------------------

Component.prototype.isDefault = function()
{
    print("isDefault");

    // select the component by default
    return true;
}

//------------------------------------------------------------------------------

Component.prototype.createOperations = function()
{
    print("createOperations");

    try
    {
        // call the base create operations function
        print("base");
        component.createOperations();

        var appLauncherPath;

        var homeDir = installer.value("homeDir");

        print("homeDir=" + homeDir);

        //----------------------------------------------------------------------
        // Windows

        if (installer.value("os") === "win")
        {
            appLauncherPath = "@TargetDir@/RiverReaches.exe";

            var appData = installer.environmentVariable("APPDATA");

            function addShortcut(exeName, lnkName, startLink, desktopLink)
            {
                var exe = "@TargetDir@/" + exeName + ".exe";

                if (startLink)
                {
                    component.addOperation("CreateShortcut", exe, "@StartMenuDir@/" + lnkName + ".lnk");
                }

                if (desktopLink)
                {
                    component.addOperation("CreateShortcut", exe, "@DesktopDir@/" + lnkName + ".lnk");
                }
            }

            if (false)
            {
                var key = "HKEY_CURRENT_USER\\Software\\Classes\\";
                var reg = installer.environmentVariable("SystemRoot") + "\\System32\\reg.exe";

                // Add registry key only if a key by same name does not already exist
                if (installer.execute(reg, new Array("QUERY", key))[1] !== 0)
                {
                    component.addOperation("Execute", "{0,1}", reg, "ADD", key, "/ve", "/f");
                    component.addOperation("Execute", "{0,1}", reg, "ADD", key, "/ve", "/d", "URL:", "/f");
                    component.addOperation("Execute", "{0,1}", reg, "ADD", key, "/v", "URL Protocol", "/t", "REG_SZ", "/f");
                    component.addOperation("Execute", "{0,1}", reg, "ADD", key + "\\shell", "/ve", "/d", "open", "/f");
                    component.addOperation("Execute", "{0,1}", reg, "ADD", key + "\\shell\\open", "/f");
                    component.addOperation("Execute", "{0,1}", reg, "ADD", key + "\\shell\\open\\command", "/ve", "/t", "REG_SZ", "/d", "\"@TargetDir@\\RiverReaches.exe\" \"%1\"", "/f");
                    component.addOperation("Execute", "{0,1}", reg, "QUERY", key, "UNDOEXECUTE", "{0,1}", reg, "DELETE", key, "/f");
                }
            }

            addShortcut("RiverReaches", "RiverReaches", true, true);

            //component.addOperation("CreateShortcut", "@TargetDir@/README.txt", "@StartMenuDir@/Read Me.lnk");
            //component.addOperation("CreateShortcut", "@TargetDir@/Licenses/EULA.pdf", "@StartMenuDir@/End User License Agreement.lnk");
        }

        //----------------------------------------------------------------------
        // MacOS

        if (installer.value("os") === "mac")
        {
            appPath = "@TargetDir@/RiverReaches.app/Contents/MacOS/RiverReaches";

            function ln(source, target)
            {
                print("Linking source=" + source + " target=" + target);

                component.addOperation("Execute", "ln", "-s", source, target, "UNDOEXECUTE", "rm", target);
            }

            function addLink(appName, niceName, appsLink, desktopLink)
            {
                print("addLink appName=" + appName + " niceName=" + niceName);

                var app = "@TargetDir@/" + appName + ".app";
                var niceApp = niceName + ".app";

                if (appsLink)
                {
                    ln(app, homeDir + "/Applications/" + niceApp);
                    //                component.addOperation("CreateShortcut",  app, homeDir + "/Applications/" + niceApp);
                    //                component.addOperation("CreateShortcut", app, "/Applications/" + niceApp);
                }

                if (desktopLink)
                {
                    ln(app, homeDir + "/Desktop/" + niceApp);
                    //                    component.addOperation("CreateShortcut", app, homeDir + "/Desktop/" + niceApp);
                }
            }

            component.addOperation("Mkdir", homeDir + "/Applications");

            addLink("RiverReaches", "RiverReaches", true, true);
        }

        //----------------------------------------------------------------------
        // Linux

        if (installer.value("os") === "x11")
        {
            function ln(source, target)
            {
                print("Linking source=" + source + " target=" + target);

                component.addOperation("Execute", "ln", "-s", source, target, "UNDOEXECUTE", "rm", target);
            }

            var binDir = "@TargetDir@/bin";
            var libDir = "@TargetDir@/lib";
            var desktopDir = "@TargetDir@/desktop";
            var scriptsDir = "@TargetDir@/scripts";
            var desktopAppsDir = homeDir + "/.local/share/applications";

            appPath = scriptsDir + "/Application.sh";

            function updateDesktop(appName, launcherLink) {
                var appPath = binDir + "/" + appName;
                var appScript = scriptsDir + "/" + "Application.sh";
                var appDesktop = desktopDir + "/" + "RiverReaches.desktop";
                //TODO
                //var appIcon = desktopDir + "/." + appName + ".png";
                var appIcon = desktopDir + "/." + "appicon.png";

                component.addOperation("Replace", appScript, "%lib%", libDir);
                component.addOperation("Replace", appScript, "%path%", appPath);
                component.addOperation("Execute", "chmod", "+x", appScript);
                component.addOperation("Replace", appDesktop, "%path%", appScript);
                component.addOperation("Replace", appDesktop, "%icon%", appIcon);

                if (launcherLink) {
                    ln(appDesktop, desktopAppsDir + "/" + appName + ".desktop");
                }
            }

            updateDesktop("RiverReaches", true);

            if (false)
            {
                component.addOperation("Execute", "update-desktop-database", "-q", desktopAppsDir, "UNDOEXECUTE", "update-desktop-database", "-q", desktopAppsDir);
            }
        }
    }
    catch (e)
    {
        print("Error: Component.prototype.createOperations");
        print(e);
    }
}
