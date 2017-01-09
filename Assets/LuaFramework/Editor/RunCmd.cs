
using System.Diagnostics;
using System.Threading;


public class RunCmd
{

    public static string cmd = "";
    //void Start()
    //{
    //    Thread newThread = new Thread(new ThreadStart(NewThread));
    //    newThread.Start();
    //}
    //public static string run(string command)
    //{
    //    //例Process
    //    Process p = new Process();
    //    p.StartInfo.FileName = "cmd.exe";           //确定程序名
    //    p.StartInfo.Arguments = "/c " + command;    //确定程式命令行
    //    p.StartInfo.UseShellExecute = false;        //Shell的使用
    //    p.StartInfo.RedirectStandardInput = true;   //重定向输入
    //    p.StartInfo.RedirectStandardOutput = true; //重定向输出
    //    p.StartInfo.RedirectStandardError = true;   //重定向输出错误
    //    p.StartInfo.CreateNoWindow = true;          //设置置不显示示窗口
    //    p.Start();
    //    return p.StandardOutput.ReadToEnd();        //输出出流取得命令行结果果
    //}
    //static void NewThread()
    //{
    //    UnityEngine.Debug.Log(run(cmd));
    //}

    public static void processCommand(string command, string argument)
    {
        ProcessStartInfo start = new ProcessStartInfo(command);
        start.Arguments = argument;
        start.CreateNoWindow = false;
        start.ErrorDialog = true;
        start.UseShellExecute = false;

        if (start.UseShellExecute)
        {
            start.RedirectStandardOutput = false;
            start.RedirectStandardError = false;
            start.RedirectStandardInput = false;
        }
        else
        {
            start.RedirectStandardOutput = true;
            start.RedirectStandardError = true;
            start.RedirectStandardInput = true;
            start.StandardOutputEncoding = System.Text.UTF8Encoding.UTF8;
            start.StandardErrorEncoding = System.Text.UTF8Encoding.UTF8;
        }

        Process p = Process.Start(start);

        if (!start.UseShellExecute)
        {
            UnityEngine.Debug.Log(p.StandardOutput.ReadToEnd());
            UnityEngine.Debug.Log(p.StandardError.ReadToEnd());
        }

        p.WaitForExit();
        p.Close();
    }
}