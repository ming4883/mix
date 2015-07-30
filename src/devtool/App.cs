//css_searchdir ../../../vendor/gwencs/GwenCS/Binaries;
//css_searchdir ../../../vendor/gwencs/GwenCS/lib/OpenTK;
//css_import ToolBase
using System;
using System.IO;
using CSScriptLibrary;
using OpenTK;
using OpenTK.Graphics;

public class App : ToolBase
{
	public bool Run (string path, string name)
	{
		try
		{
			/*
			string asmName = string.Format ("~{0}.dll", name);
			using (var script = new AsmHelper (CSScript.Load (path, asmName, false, null)))
			using (ToolBase tool = script.CreateObject ("Tool") as ToolBase)
			using (GameWindow gamewindow = new GameWindow (720, 480, GraphicsMode.Default, name))
			{
				Console.WriteLine ("Example {0} running", name);
				example.Init (gamewindow);
				gamewindow.Run (60.0f);
				Console.WriteLine ("Example {0} finished", name);
			}
			*/
		}
		catch (Exception err)
		{
			Console.WriteLine ("Tool {0} failed\n{1}", name, err);
		}
		
		return true;
	}

	public override void PostLoad ()
	{
		{
			Gwen.Control.GroupBox gb = new Gwen.Control.GroupBox (canvas);
			gb.Dock = Gwen.Pos.Top;
			gb.Text = "Projects";
			gb.Height = 50;
			gb.Margin = Gwen.Margin.Five;
			
			Gwen.Control.ComboBox prjs = new Gwen.Control.ComboBox (gb);
			prjs.Dock = Gwen.Pos.Fill;
			prjs.Margin = Gwen.Margin.Five;
			
			string[] skipList = {".git", "build", "common", "vendor"};
			
			foreach (string dir in Directory.GetDirectories ("../../../"))
			{
				string name = Path.GetFileName (dir);
				
				if (null != Array.Find (skipList, (i) => { return string.Compare (i, name) == 0;}))
				{
					continue;
				}
				
				prjs.AddItem (name, Path.GetFullPath (dir));
			}
		}
		{
			Gwen.Control.GroupBox gb = new Gwen.Control.GroupBox (canvas);
			gb.Dock = Gwen.Pos.Fill;
			gb.Text = "Actions";
			gb.Margin = Gwen.Margin.Five;
			
		}
	}
	
	public static void Main (string[] args)
	{
		using (GameWindow gamewindow = new GameWindow (640, 480, GraphicsMode.Default, "DevTool"))
		using (App app = new App())
		{
			app.Init (gamewindow);
			gamewindow.Run (60.0);
		}
	}
}
