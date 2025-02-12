require "import"
import "mods.muk"
import "com.google.android.material.tabs.TabLayout"

设置视图("layout/topic")
edgeToedge(nil,nil,function() local layoutParams = topbar.LayoutParams;
  layoutParams.setMargins(layoutParams.leftMargin, 状态栏高度, layoutParams.rightMargin,layoutParams.bottomMargin);
  topbar.setLayoutParams(layoutParams); end)
设置toolbar(toolbar)
topic_id=...
波纹({fh,_more},"圆主题")

初始化历史记录数据()

local topic_pages={
  ScrollView;
  nestedScrollingEnabled=true,
  layout_width=-1;
  layout_height=-1;
  {
    LinearLayout;
    layout_height="-1",
    layout_width="-1",
    {
      MaterialCardView;
      layout_height="-2";
      CardBackgroundColor=cardedge,
      Elevation="0";
      layout_width="-1";
      layout_margin="16dp";
      layout_marginTop="8dp";
      layout_marginBottom="8dp";
      radius=cardradius;
      StrokeColor=cardedge;
      StrokeWidth=dp2px(1),
      {
        LinearLayout;
        layout_width="-1",
        orientation="vertical";
        {
          CircleImageView;
          layout_gravity="center";
          layout_marginTop="16dp",
          layout_height="72dp",
          layout_width="72dp",
          id="_bigimage"
        };
        {
          TextView;
          id="_excerpt",
          textColor=textc,
          textSize=内容文字大小,
          Typeface=字体("product");
          textIsSelectable=true;
          layout_margin="16dp",
          layout_marginBottom="8dp",
        };
      };
    };
  };
};

pagadp=SWKLuaPagerAdapter()

pagadp.add(loadlayout(topic_pages))
topic_page.setAdapter(pagadp)



local base_topic=require "model.topic":new(topic_id)
:getData(function(data)
  _title.text=data.name
  loadglide(_image,data.avatar_url,false)
  loadglide(_bigimage,data.avatar_url,false)
  if data.introduction==""then
    _excerpt.text="暂无话题描述"
   else
    _excerpt.text=data.introduction
  end
end)

function 获取url(type)
  return "https://api.zhihu.com/v5.1/topics/"..topic_id.."/feeds/"..type
end

urltypes={
  [1]={
    essence="essence",
    new="timeline_activity",
    hot="top_activity"
  },
  [2]={
    new="pin-new",
    hot="pin-hot"
  },
  [3]={
    new="new_zvideo",
    hot="top_zvideo"
  },
  [4]={
    new="new_question",
    hot="top_question"
  },
}

pop={
  tittle="话题",
  list={
    {src=图标("insert_chart"),text="按精华排序",onClick=function()
        topic_pagetool:setUrlItem(获取url(urltypes[pos]["essence"]),pos)
        topic_pagetool:clearItem(pos)
        :refer(pos,nil,true)
    end},
    {src=图标("format_align_left"),text="按时间顺序",onClick=function()
        topic_pagetool:setUrlItem(获取url(urltypes[pos]["new"]),pos)
        topic_pagetool:clearItem(pos)
        :refer(pos,nil,true)
    end},
    {src=图标("notes"),text="按热度顺序",onClick=function()
        topic_pagetool:setUrlItem(获取url(urltypes[pos]["hot"]),pos)
        :clearItem(pos)
        :refer(pos,nil,true)
    end},
  }
}

task(1,function()
  a=MUKPopu(pop)
end)

topic_pagetool=base_topic:initpage(topic_page,TopictabLayout)
:setOnTabListener(function(self,pos)
  _G["pos"]=pos
  if pos==1 then
    a=MUKPopu(pop)
   elseif pos==0 then
    local pop=table.clone(pop)
    pop.list={}
    pop.isload_codeEx=false
    a=MUKPopu(pop)
   else
    local pop=table.clone(pop)
    table.remove(pop.list,1)
    a=MUKPopu(pop)
  end
end)

topic_page.setCurrentItem(1,false)

if activity.getSharedData("话题提示0.01")==nil
  AlertDialog.Builder(this)
  .setTitle("小提示")
  .setCancelable(false)
  .setMessage("你可以点击右上角切换排列顺序哦")
  .setPositiveButton("我知道了",{onClick=function() activity.setSharedData("话题提示0.01","true") end})
  .show()
end