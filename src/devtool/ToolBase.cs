//css_reference "OpenTK.dll"
//css_reference "Gwen.dll"
//css_reference "Gwen.Renderer.OpenTK.dll"
//css_reference "System.Drawing.dll"
using System;
using OpenTK;
using OpenTK.Graphics;
using OpenTK.Graphics.OpenGL;

public class ToolBase : IDisposable
{
	protected Gwen.Renderer.OpenTK renderer;
	protected Gwen.Skin.Base skin;
	protected Gwen.Control.Canvas canvas;
	protected Gwen.Input.OpenTK input;
	
	public void Init (GameWindow gamewindow)
	{
		renderer = new Gwen.Renderer.OpenTK();
		skin = new Gwen.Skin.TexturedBase (renderer, "DefaultSkin.png");
		canvas = new Gwen.Control.Canvas (skin);
		canvas.SetSize (gamewindow.Width, gamewindow.Height);
		canvas.ShouldDrawBackground = true;
		canvas.BackgroundColor = System.Drawing.Color.FromArgb (255, 225, 225, 225);

		input = new Gwen.Input.OpenTK (gamewindow);
		input.Initialize (canvas);
		
		gamewindow.Keyboard.KeyDown += (s, e) =>
		{
			input.ProcessKeyDown (e);
		};
		gamewindow.Keyboard.KeyUp += (s, e) =>
		{
			input.ProcessKeyUp (e);
		};

		gamewindow.Mouse.ButtonDown += (s, e) =>
		{
			input.ProcessMouseMessage (e);
		};
		gamewindow.Mouse.ButtonUp += (s, e) =>
		{
			input.ProcessMouseMessage (e);
		};
		gamewindow.Mouse.Move += (s, e) =>
		{
			input.ProcessMouseMessage (e);
		};
		gamewindow.Mouse.WheelChanged += (s, e) =>
		{
			input.ProcessMouseMessage (e);
		};

		gamewindow.Load += (s, e) =>
		{
			PreLoad();
			
			gamewindow.VSync = VSyncMode.On;
			
			PostLoad();
		};
		
		gamewindow.Resize += (s, e) =>
		{
			GL.Viewport (0, 0, gamewindow.Width, gamewindow.Height);
			GL.MatrixMode (MatrixMode.Projection);
			GL.LoadIdentity();
			GL.Ortho (0, gamewindow.Width, gamewindow.Height, 0, -1, 1);

			canvas.SetSize (gamewindow.Width, gamewindow.Height);
		};
		
		gamewindow.UpdateFrame += (s, e) =>
		{
			PreUpdate();
			
			if (renderer.TextCacheSize > 1000)
				renderer.FlushTextCache();
			
			PostUpdate();
		};
		
		gamewindow.RenderFrame += (s, e) =>
		{
			gamewindow.MakeCurrent();
			
			PreRender();
			
			canvas.RenderCanvas();
			
			PostRender();
			
			gamewindow.SwapBuffers();
		};
	}
	
	public void Dispose()
	{
		canvas.Dispose();
		skin.Dispose();
		renderer.Dispose();
	}
	
	public virtual void PreLoad()
	{
	}
	
	public virtual void PostLoad()
	{
	}
	
	public virtual void PreUpdate()
	{
	}
	
	public virtual void PostUpdate()
	{
	}
	
	public virtual void PreRender()
	{
	}
	
	public virtual void PostRender()
	{
	}
}
