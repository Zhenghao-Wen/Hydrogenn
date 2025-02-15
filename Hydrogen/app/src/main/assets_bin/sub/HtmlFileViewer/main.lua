require "import"
-- 新增 使用自定义toolbar
useCustomAppToolbar=true
import "jesse205"
import "android.text.Html"
import "com.onegravity.rteditor.RTEditorMovementMethod"--可以选择与点击的MovementMethod
import "me.zhanghai.android.fastscroll.FastScrollerBuilder"
import "me.zhanghai.android.fastscroll.FastScrollScrollView"

--activity.setTitle(R.string.jesse205_htmlFileViewer)

import "com.google.android.material.appbar.AppBarLayout"
import "com.google.android.material.appbar.MaterialToolbar"
import "androidx.appcompat.widget.LinearLayoutCompat"
import "androidx.core.widget.NestedScrollView"

local luapath=File(this.getLuaDir()).getParentFile().getParentFile().toString()
package.path = package.path..";"..luapath.."/?.lua"
require("mods.muk")

activity.setContentView(loadlayout("layout"))
activity.setSupportActionBar(toolbar)
--actionBar.setDisplayHomeAsUpEnabled(true)

设置toolbar属性(toolbar,R.string.jesse205_htmlFileViewer)

---传入的数据
local data=...

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

function onConfigurationChanged(config)
  --刷新ActionBar阴影
  MyAnimationUtil.ScrollView.onScrollChange(scrollView,scrollView.getScrollX(),scrollView.getScrollY(),0,0)
end

textView.setLinksClickable(true)
textView.setMovementMethod(RTEditorMovementMethod.getInstance())
textView.requestFocusFromTouch()

FastScrollerBuilder(scrollView).useMd2Style().build()

if data.title then
  activity.setTitle(data.title)
end

local path=data.path
local url=data.url
if path then
  local content=io.open(path,"r"):read("*a")
  if tostring(data.text)=="true" then
    textView.setText(content)
   else
    textView.setText(Html.fromHtml(content))
  end
end

scrollView.onScrollChange=function(view,l,t,oldl,oldt)
  MyAnimationUtil.ScrollView.onScrollChange(view,l,t,oldl,oldt)
end
