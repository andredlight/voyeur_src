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

import java.io.IOException;

public class RubotoBroadcastReceiver extends android.content.BroadcastReceiver {
    private String scriptName = null;
    private Object rubyInstance;

    public void setCallbackProc(int id, Object obj) {
        // Error: no callbacks
        throw new RuntimeException("RubotoBroadcastReceiver does not accept callbacks");
    }
	
    public void setScriptName(String name){
        scriptName = name;
    }

    public RubotoBroadcastReceiver() {
        this(null);
    }

    public RubotoBroadcastReceiver(String name) {
        super();

        if (name != null) {
            setScriptName(name);
        
            if (JRubyAdapter.isInitialized()) {
                loadScript();
            }
        }
    }

    protected void loadScript() {

        // TODO(uwe):  Only needed for non-class-based definitions
        // Can be removed if we stop supporting non-class-based definitions
    	JRubyAdapter.put("$broadcast_receiver", this);
    	// TODO end

        if (scriptName != null) {
            try {
                String rubyClassName = Script.toCamelCase(scriptName);
                System.out.println("Looking for Ruby class: " + rubyClassName);
                Object rubyClass = JRubyAdapter.get(rubyClassName);
                if (rubyClass == null) {
                    System.out.println("Loading script: " + scriptName);
                    JRubyAdapter.exec(new Script(scriptName).getContents());
                    rubyClass = JRubyAdapter.get(rubyClassName);
                }
                if (rubyClass != null) {
                    System.out.println("Instanciating Ruby class: " + rubyClassName);
                    rubyInstance = JRubyAdapter.callMethod(rubyClass, "new", this, Object.class);
                }
            } catch(IOException e) {
                throw new RuntimeException("IOException loading broadcast receiver script", e);
            }
        }
    }

    public void onReceive(android.content.Context context, android.content.Intent intent) {
        try {
            System.out.println("onReceive: " + rubyInstance);
            if (rubyInstance != null) {
            	JRubyAdapter.callMethod(rubyInstance, "on_receive", new Object[]{context, intent});
            } else {
                // TODO(uwe):  Only needed for non-class-based definitions
                // Can be removed if we stop supporting non-class-based definitions
                JRubyAdapter.put("$context", context);
                JRubyAdapter.put("$broadcast_receiver", this);
                JRubyAdapter.put("$intent", intent);
            	JRubyAdapter.execute("$broadcast_receiver.on_receive($context, $intent)");
            	// TODO end
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
}	
