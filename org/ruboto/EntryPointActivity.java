/*
This file is part of com.andredlight.voyeur.

    com.andredlight.voyeur is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    com.andredlight.voyeur is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with com.andredlight.voyeur.  If not, see <http://www.gnu.org/licenses/>.
*/

package org.ruboto;

import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

public class EntryPointActivity extends org.ruboto.RubotoActivity {
    private int splash = 0;
    private ProgressDialog loadingDialog;
    private boolean dialogCancelled = false;
    private BroadcastReceiver receiver;
    protected boolean appStarted = false;

	public void onCreate(Bundle bundle) {
        Log.d("onCreate: ");

	    try {
    		splash = Class.forName(getPackageName() + ".R$layout").getField("splash").getInt(null);
		} catch (Exception e) {
		    splash = -1;
		}

        if (JRubyAdapter.isInitialized()) {
            appStarted = true;
		}
	    super.onCreate(bundle);
	}

    public void onResume() {
        Log.d("onResume: ");

        if(appStarted) {
            Log.d("onResume: App already started!");
            super.onResume();
            return;
        }

        Log.d("onResume: Checking JRuby");
        if (JRubyAdapter.isInitialized()) {
            Log.d("Already initialized");
    	    fireRubotoActivity();
        } else {
            Log.d("Not initialized");
            showProgress();
            receiver = new BroadcastReceiver(){
                public void onReceive(Context context, Intent intent) {
                    Log.i("received broadcast: " + intent);
                    Log.i("URI: " + intent.getData());
                    if (intent.getData().toString().equals("package:org.ruboto.core")) {
                        Toast.makeText(context,"Ruboto Core is now installed.",Toast.LENGTH_SHORT).show();
                        if (receiver != null) {
                    	    unregisterReceiver(receiver);
                    	    receiver = null;
                        }
                        showProgress();
                        initJRuby(false);
                    }
                }
            };
            IntentFilter filter = new IntentFilter(Intent.ACTION_PACKAGE_ADDED);
            filter.addDataScheme("package");
            registerReceiver(receiver, filter);
            initJRuby(true);
            super.onResume();
        }
    }

    public void onPause() {
        Log.d("onPause: ");

        if (receiver != null) {
    	    unregisterReceiver(receiver);
    	    receiver = null;
        }
        super.onPause();
    }

    public void onDestroy() {
        Log.d("onDestroy: ");

        super.onDestroy();
        if (dialogCancelled) {
            System.runFinalizersOnExit(true);
            System.exit(0);
        }
    }

    private void initJRuby(final boolean firstTime) {
        new Thread(new Runnable() {
            public void run() {
                final boolean jrubyOk = JRubyAdapter.setUpJRuby(EntryPointActivity.this);
                if (jrubyOk) {
                    Log.d("onResume: JRuby OK");
                    prepareJRuby();
                    runOnUiThread(new Runnable() {
                        public void run() {
                            fireRubotoActivity();
                        }
                    });
                } else {
                    runOnUiThread(new Runnable() {
                        public void run() {
                            if (firstTime) {
                                Log.d("onResume: Checking JRuby - IN UI thread");
                                try {
                                    setContentView(Class.forName(getPackageName() + ".R$layout").getField("get_ruboto_core").getInt(null));
                                } catch (Exception e) {
                                }
                            } else {
                                Toast.makeText(EntryPointActivity.this,"Failed to initialize Ruboto Core.",Toast.LENGTH_SHORT).show();
                                try {
                                    TextView textView = (TextView) findViewById(Class.forName(getPackageName() + ".R$id").getField("text").getInt(null));
                                    textView.setText("Woops!  Ruboto Core was installed, but it failed to initialize properly!  I am not sure how to proceed from here.  If you can, please file an error report at http://ruboto.org/");
                                } catch (Exception e) {
                                }
                            }
                            hideProgress();
                        }
                    });
                }
            }
        }).start();
    }

	private static final String RUBOTO_APK = "RubotoCore-release.apk";
	private static final String RUBOTO_URL = "https://github.com/downloads/ruboto/ruboto/" + RUBOTO_APK;

    // Called when the button is pressed.
    public void getRubotoCore(View view) {
        try {
            startActivity(new Intent(Intent.ACTION_VIEW).setData(Uri.parse("market://details?id=org.ruboto.core")));
        } catch (android.content.ActivityNotFoundException anfe) {
            try {
                Intent intent = new Intent(android.content.Intent.ACTION_VIEW, Uri.parse(RUBOTO_URL));
                startActivity(intent);
            } catch (Exception e) {}
        }
    }

    protected void fireRubotoActivity() {
        if(appStarted) return;
        appStarted = true;
        Log.i("Starting activity");
        loadScript();
        onStart();
        super.onResume();
        hideProgress();
    }

    private void showProgress() {
        if (loadingDialog == null) {
            Log.i("Showing progress");
            if (splash > 0) {
                requestWindowFeature(android.view.Window.FEATURE_NO_TITLE);
                setContentView(splash);
            } else {
                loadingDialog = ProgressDialog.show(this, null, "Starting...", true, true);
                loadingDialog.setCanceledOnTouchOutside(false);
                loadingDialog.setOnCancelListener(new OnCancelListener() {
                    public void onCancel(DialogInterface dialog) {
                        dialogCancelled = true;
                        finish();
                    }
                });
            }
        }
    }

    private void hideProgress() {
        if (loadingDialog != null) {
            Log.d("Hide progress");
            loadingDialog.dismiss();
            loadingDialog = null;
        }
    }

}
