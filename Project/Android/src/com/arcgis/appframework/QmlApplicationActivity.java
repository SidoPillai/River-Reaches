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

package com.arcgis.appframework;

import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.net.Uri;
import android.os.Bundle;
import android.os.Build;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

//------------------------------------------------------------------------------

public class QmlApplicationActivity extends org.qtproject.qt5.android.bindings.QtActivity
{
    public static native void consoleLog(String text);
    public static native void openUrl(String url);

    //--------------------------------------------------------------------------

    private static QmlApplicationActivity m_Instance;

    //--------------------------------------------------------------------------

    public QmlApplicationActivity()
    {
        m_Instance = this;
    }

    //--------------------------------------------------------------------------

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        consoleLog("onCreate");

        Intent intent = getIntent();

        Uri uri = intent.getData();
        if (uri != null)
        {
            openUrl(uri.toString());
        }

        if (isXLargeScreen(getApplicationContext()))
        {
            consoleLog("Tablet");

            if (!true)
            {
                //set tablets to portrait;
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT);

                //set tablets to landscape;
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
            }
        }
        else
        {
            consoleLog("Phone");

            if (!true)
            {
                //set phones to portrait;
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT);

                //set phones to landscape;
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
            }
        }
    }

    //---------------------------------------------------------------------------

    @Override
    protected void onResume()
    {
        super.onResume();

        if (isXLargeScreen(getApplicationContext()))
        {
            // Tablet
            //hideStatusBar();
        }
        else
        {
            // Phone
            //hideStatusBar();
        }
    }

    //--------------------------------------------------------------------------

    @Override
    public void onNewIntent(Intent intent)
    {
        super.onNewIntent(intent);

        consoleLog("onNewIntent");

        Uri uri = intent.getData();
        if (uri != null)
        {
            openUrl(uri.toString());
        }
    }

    //--------------------------------------------------------------------------

    public static boolean isXLargeScreen(Context context)
    {
        int screenLayout = context.getResources().getConfiguration().screenLayout;

        return ((screenLayout & Configuration.SCREENLAYOUT_SIZE_MASK) >= Configuration.SCREENLAYOUT_SIZE_XLARGE);
    }

    //--------------------------------------------------------------------------

    public void hideStatusBar()
    {
        try {
            if (Build.VERSION.SDK_INT < 16) {
                //Android 4.0 and Lower
                getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                               WindowManager.LayoutParams.FLAG_FULLSCREEN);
            } else {
                // Android 4.1 and Higher
                View decorView = getWindow().getDecorView();
                int uiOptions = View.SYSTEM_UI_FLAG_FULLSCREEN;
                decorView.setSystemUiVisibility(uiOptions);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    //--------------------------------------------------------------------------
}

//------------------------------------------------------------------------------

