using System;
using System.IO;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;

public class Builder : MonoBehaviour
{
    public static void BuildProject()
    {
        try
        {
            File.WriteAllText("/build/BuildPlayer.log", "BuildPlayer started");   
            var target = EditorUserBuildSettings.activeBuildTarget;
            var scenePaths = File.ReadAllLines("SceneList");
            var options = BuildOptions.Development | BuildOptions.AllowDebugging;
            var output = "/build";
        
            switch (target)
            {
                case BuildTarget.Android:
                    EditorUserBuildSettings.exportAsGoogleAndroidProject = true;
                    break;
            
                case BuildTarget.StandaloneWindows64:
                    EditorUserBuildSettings.SetPlatformSettings("Standalone", "CreateSolution", "true");
                    output += "/built_player.exe";
                    break;
            
                case BuildTarget.iOS:
                    //  Always an "export"
                    break;
            
                default:
                    throw new ArgumentOutOfRangeException($"Unknown platform: {Application.platform}");
            }

            var buildReport = BuildPipeline.BuildPlayer(scenePaths, output, target, options);

            if (buildReport.summary.result == BuildResult.Succeeded)
            {
                Debug.Log("BuildPlayer finished successfully");
            }
            else
            {
                Debug.LogError("BuildPlayer finished with " + buildReport.summary.totalErrors + " errors");
            }

            Debug.Log("Files in /build: " + string.Join(", ", Directory.GetFiles("/build")));
            Debug.Log("Directories in /build: " + string.Join(", ", Directory.GetDirectories("/build")));

            EditorApplication.Exit(0);
        }
        catch (Exception e)
        {
            Debug.LogError(e);

            EditorApplication.Exit(1);
        }
    }
}
