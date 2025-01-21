require "import"
import "android.widget.*"
import "android.view.*"
import "mods.muk"
import "android.text.method.LinkMovementMethod"
import "com.google.android.material.bottomsheet.*"
import "com.google.android.material.chip.ChipGroup"
import "com.google.android.material.chip.Chip"

comment_id,comment_type,保存路径,父回复id=...

import "com.google.android.material.floatingactionbutton.FloatingActionButton"

activity.setContentView(loadlayout("layout/comment"))


波纹({fh,_more},"圆主题")

function 发送评论()
  if not(getLogin()) then
    return 提示("请登录后使用本功能")
  end

  local mytext
  local postdata
  local 请求链接

  local 回复id=""

  if comment_type=="comments" then
    回复id=comment_id
  end

  local bottomSheetDialog = BottomSheetDialog(this)
  bottomSheetDialog.setContentView(loadlayout({
    LinearLayoutCompat;
    orientation="vertical";
    layout_height="fill";
    layout_width="fill";
    {
      LinearLayout;
      layout_width="fill";
      layout_height="fill";
      gravity="center";
      Focusable=true;
      FocusableInTouchMode=true;
      --开启动画可能造成卡顿
      --LayoutTransition=LayoutTransition().enableTransitionType(LayoutTransition.CHANGING);
      {
        EditText;
        id="send_edit";
        layout_weight=1;
        layout_marginLeft="16dp";
        layout_margin="8dp";
        maxLines=10;
        hint="输入评论";
      };
      {
        MaterialButton;
        layout_marginRight="10dp";
        id="send";
        textColor=backgroundc;
        text="发送";
      };
    };
  }))

  send_edit.requestFocus()
  send_edit.postDelayed(Runnable{
    run=function()
      local imm= this.getSystemService(Context.INPUT_METHOD_SERVICE);
      imm.showSoftInput(send_edit, InputMethodManager.SHOW_IMPLICIT);
    end
  }, 100);


  bottomSheetDialog.show()
  bottomSheetDialog.setCancelable(true);


  send.onClick=function()
    --测试不通过unicode编码也可以 暂时这么解决
    --或许之后知乎会仅支持unicode 到时候下载知乎app分析一下

    --替换 防止发表评论提交多行知乎api报错
    local mytext=send_edit.text
    --回车
    :gsub("\r","\\u000D")
    --换行
    :gsub("\n","\\u000A")

    --评论类型和评论id处理逻辑在comment_base
    local postdata='{"comment_id":"","content":"'..mytext..'","extra_params":"","has_img":false,"reply_comment_id":"'..回复id..'","score":0,"selected_settings":[],"sticker_type":null,"unfriendly_check":"strict"}'
    local 请求链接="https://api.zhihu.com/comment_v5/"..评论类型.."/"..评论id.."/comment"

    local url,head=require "model.zse96_encrypt"(请求链接)
    zHttp.post(url,postdata,head,function(code,json)
      if code==200 then
        提示("发送成功 如若想看到自己发言请刷新数据")
        bottomSheetDialog.dismiss()
      end
    end)
  end

end



if comment_type=="local_chat" then
  internetnet.setVisibility(8)
  localcomment.setVisibility(0)

  comment_itemc=获取适配器项目布局("comment/comments_reply")

  sadapter=LuaAdapter(activity,comment_itemc)
  local_comment_list.setAdapter(sadapter)

  function getCommentData(filename, func)
    local file = io.open(filename, "r")
    local currentAuthor = nil
    local currentContentBuffer = ""

    for line in file:lines() do
      -- 检查是否开始一个新的author行
      if line:find('author="') then
        currentAuthor = line:match('author="([^"]+)"')
        currentContentBuffer = "" -- 重置content缓冲区
       else
        -- 累积content，直到找到结束引号
        currentContentBuffer = currentContentBuffer .. line
        local contentEndIndex = currentContentBuffer:find('"', 10) -- content从第10个字符开始
        if contentEndIndex then
          local currentContent = currentContentBuffer:sub(9, contentEndIndex - 1)
          func(currentAuthor, currentContent)
          currentAuthor = nil
          currentContentBuffer = "" -- 处理完一对后重置缓冲区
        end
      end
    end

    file:close()
  end


  getCommentData(comment_id,function(用户名,内容)
    local myspan
    if 内容:find("https?://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]") then
      myspan=setstyle(Html.fromHtml(内容))
     else
      myspan=Html.fromHtml(内容)
    end


    sadapter.add{
      标题=用户名,
      预览内容={
        text=myspan,
        MovementMethod=LinkMovementMethod.getInstance(),
        Focusable=false,
        onLongClick=function(v)
          复制文本=v.Text
          import "android.content.*"
          activity.getSystemService(Context.CLIPBOARD_SERVICE).setText(复制文本)
          提示("复制文本成功")
        end
      },
      提示内容={Visibility=8}
    }

  end)


  --对话列表 显示第一个的提示内容
  local_comment_list.adapter.getData()[1].提示内容.Visibility=0
  local_comment_list.adapter.notifyDataSetChanged()

  local_comment_list.setOnItemClickListener(AdapterView.OnItemClickListener{
    onItemClick=function(id,v,zero,one)
      if v.Tag.提示内容.getVisibility()==0 then
        提示("当前已在该对话列表内")
      end
  end})

  _title.text="对话列表"
 elseif comment_type=="local" then
  internetnet.setVisibility(8)
  local_comment_list.setVisibility(0)

  comment_itemc=获取适配器项目布局("comment/comments_reply")

  sadapter=LuaAdapter(activity,comment_itemc)
  local_comment_list.setAdapter(sadapter)

  function isAuthorMentionedMoreThanOnce(s)
    local count = 0
    local pos = 1

    while true do
      local findPos = string.find(s, "author", pos)
      if findPos then
        count = count + 1
        pos = findPos + 1
        if count > 1 then -- 当计数超过1时，直接返回true
          return "true"
        end
       else
        break
      end
    end

    return "false" -- 如果循环结束还没有返回，说明计数不超过1，返回false
  end

  for v,s in pairs(luajava.astable(File(保存路径.."/".."fold/").listFiles())) do
    local xxx=读取文件(tostring(s))
    local name=xxx:match('author="([^"]*)"')
    local content=xxx:match('content="(.-)"')
    local iscomments=isAuthorMentionedMoreThanOnce(xxx)
    id=s.Name
    sadapter.add{标题=name,
      预览内容={
        text=content,
        onLongClick=function(v)
          复制文本=v.Text
          import "android.content.*"
          activity.getSystemService(Context.CLIPBOARD_SERVICE).setText(复制文本)
          提示("复制文本成功")
        end
      },
      提示内容={
        Visibility=(iscomments=="false" and 8 or 0)
      },
      id内容=id
    }

  end

  _title.text="保存的评论".." "..#local_comment_list.adapter.getData().."条"

  local_comment_list.setOnItemClickListener(AdapterView.OnItemClickListener{
    onItemClick=function(id,v,zero,one)
      if v.Tag.提示内容.getVisibility()==0 then
        activity.newActivity("comment",{保存路径.."/fold/"..v.Tag.id内容.text,"local_chat"})
      end
  end})
end

if not(comment_type:find("local")) then
  send.onClick=function()
    local send_edit=edit
    发送评论(send_edit)
  end
  踩tab={}
  comment_item=获取适配器项目布局("comment/comment")
  if comment_type=="comments" then
    --楼中楼
    _title.text="对话列表"
  end
  --评论
  comment_base=require "model.comment"
  :new(comment_id,comment_type)
  comment_pagetool=comment_base
  :initpage(comment_recy,commentsr)
end


task(1,function()
  a=MUKPopu({
    tittle="评论",
    list={
      {src=图标("format_align_left"),text="按时间顺序",onClick=function()
          local comment_pagetool,comment_base=_G["comment_pagetool"],_G["comment_base"]
          comment_pagetool:setUrlItem(comment_base:getUrlByType("ts"))
          :clearItem()
          :refer(nil,nil,true)
      end},
      {src=图标("notes"),text="按默认顺序",onClick=function()
          local comment_pagetool,comment_base=_G["comment_pagetool"],_G["comment_base"]
          comment_pagetool:setUrlItem(comment_base:getUrlByType("score"))
          :clearItem()
          :refer(nil,nil,true)
      end},
    }
  })
end)

if comment_type:find("local") then
  task(1,function()
    a=MUKPopu({
      tittle=_title.text,
      list={

      }
    })
  end)
end

function onActivityResult(a,b,c)
  if b==100 then
    if comment_type~="local" then
      comment_base:clear()
      comment_list.Adapter.clear()
    end
  end
end