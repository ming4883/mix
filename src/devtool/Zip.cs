//css_reference "System.IO.Compression.dll"
using System;
using System.IO;
using System.IO.Compression;
using System.Collections;
using System.Collections.Generic;

public class Zip
{
	
	public Dictionary<string, string> m_entries = new Dictionary<string, string>();
	public string m_output;
	
	public void Begin (string output)
	{
		m_entries.Clear();
		m_output = output;
	}
	
	private void AddDirImpl (string curr, string root)
	{
		foreach (string file in Directory.GetFiles (curr))
		{
			string key = file.Replace (root, "").Replace("\\", "/");
			string val = Path.GetFullPath (file);
			
			if (string.Compare (val, m_output, true) == 0)
				continue;
			
			if (m_entries.ContainsKey (key))
			{
				Console.WriteLine ("Overwritting {0} with {1}", key, val);
				m_entries.Remove (key);
			}
			
			m_entries.Add (key, val);
		}
		
		foreach (string dir in Directory.GetDirectories (curr))
		{
			AddDirImpl (dir, root);
		}
	}
	
	public void AddDir (string path)
	{
		if (!Directory.Exists (path))
		{
			Console.WriteLine ("dir {0} does not exists", path);
			return;
		}
		
		string root = path.Replace ("/", "\\");
		
		if (!root.EndsWith("\\"))
		{
			root = root + "\\";
		}
		
		AddDirImpl (root, root);
	}
	
	public void End ()
	{
		using (ZipArchive za = new ZipArchive (File.OpenWrite (m_output), ZipArchiveMode.Create))
		{
			foreach (KeyValuePair<string, string> _ in m_entries)
			{
				ZipArchiveEntry zae = za.CreateEntry (_.Key, CompressionLevel.Fastest);
				using (Stream dst = zae.Open())
				using (Stream src = File.OpenRead (_.Value))
				{
					src.CopyTo (dst);
				}
			}
		}
	}
	
	public static int Main (string[] args)
	{
		try
		{
			string output = Path.GetFullPath (args[0]);
			
			//Console.WriteLine ("Output to {0}", output);
			
			Zip zip = new Zip();
			zip.Begin (output);
			
			for (int i = args.Length - 1; i >= 1; --i)
				zip.AddDir (args[i]);
			
			zip.End();
		}
		catch (Exception err)
		{
			Console.WriteLine ("Exception caught {0}", err);
			return 1;
		}
		
		return 0;
	}
}
