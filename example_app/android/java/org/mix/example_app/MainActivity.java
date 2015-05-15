package org.mix.example_app;

import org.mix.dummy.Dummy;

public class MainActivity extends org.mix.common.BaseActivity {

	@Override
    protected String[] getLibraries() {
        Dummy.echo("getLibraries()");
        return new String[] {
            "gnustl_shared",
            "example_app"
        };
    }
}
