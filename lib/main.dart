import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() => runApp(const MorrowApp());

const ink=Color(0xFF172923), muted=Color(0xFF7D8982), paper=Color(0xFFF5F7F1);
const lime=Color(0xFFC5F477), forest=Color(0xFF28614F), coral=Color(0xFFFF9675);

class MorrowApp extends StatelessWidget {
  const MorrowApp({super.key});
  @override Widget build(BuildContext context)=>MaterialApp(
    debugShowCheckedModeBanner:false, title:'Morrow Finance',
    theme:ThemeData(useMaterial3:true,scaffoldBackgroundColor:paper,fontFamily:'Arial',colorScheme:ColorScheme.fromSeed(seedColor:forest)),
    home:const HomePage());
}
class Entry {
  Entry(this.name,this.category,this.amount,this.income,this.when,this.icon);
  final String name,category,when; final double amount; final bool income; final IconData icon;
}
class HomePage extends StatefulWidget {const HomePage({super.key}); @override State<HomePage> createState()=>_HomePageState();}
class _HomePageState extends State<HomePage> {
 int page=0; String filter='All';
 final entries=<Entry>[
  Entry('Monthly salary','Income',5200,true,'Today · 9:10 AM',Icons.account_balance_wallet_rounded),
  Entry('Whole Foods Market','Groceries',86.40,false,'Today · 8:32 AM',Icons.shopping_basket_rounded),
  Entry('Blue Bottle Coffee','Food & drink',12.80,false,'Yesterday · 4:18 PM',Icons.coffee_rounded),
  Entry('City transport','Transport',24.50,false,'Yesterday · 9:02 AM',Icons.train_rounded),
  Entry('Netflix subscription','Entertainment',15.99,false,'Nov 10 · 11:20 AM',Icons.play_circle_rounded),
  Entry('Freelance project','Income',780,true,'Nov 09 · 2:45 PM',Icons.laptop_mac_rounded),
 ];
 double get income=>entries.where((e)=>e.income).fold(0,(a,e)=>a+e.amount);
 double get spent=>entries.where((e)=>!e.income).fold(0,(a,e)=>a+e.amount);
 String cash(double v) {
  final parts = v.toStringAsFixed(2).split('.');
  final number = parts[0];

  if (number.length <= 3) {
   return '₹$number.${parts[1]}';
  }

  final lastThree = number.substring(number.length - 3);
  var remaining = number.substring(0, number.length - 3);
  final groups = <String>[];

  while (remaining.length > 2) {
   groups.insert(0, remaining.substring(remaining.length - 2));
   remaining = remaining.substring(0, remaining.length - 2);
  }

  if (remaining.isNotEmpty) groups.insert(0, remaining);

  return '₹${groups.join(',')},$lastThree.${parts[1]}';
 }
 BoxDecoration card()=>BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(21),border:Border.all(color:const Color(0xFFE8ECE4)));
 void addEntry() {
  final name=TextEditingController(), amount=TextEditingController(); String category='Food & drink'; bool incoming=false;
  showDialog(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,local)=>AlertDialog(
   shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(24)),title:const Text('Add an entry',style:TextStyle(fontWeight:FontWeight.w800)),
   content:SizedBox(width:360,child:Column(mainAxisSize:MainAxisSize.min,children:[
    TextField(controller:name,decoration:const InputDecoration(labelText:'Description',prefixIcon:Icon(Icons.edit_rounded))),
    TextField(controller:amount,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Amount',prefixText:'\$ ')),
    const SizedBox(height:10),
    DropdownButtonFormField<String>(value:category,decoration:const InputDecoration(labelText:'Category'),items:['Food & drink','Groceries','Transport','Shopping','Entertainment','Income','Other'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),onChanged:(v)=>local(()=>category=v!)),
    SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('Money coming in'),value:incoming,activeColor:forest,onChanged:(v)=>local(()=>incoming=v))
   ])),
   actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Cancel')),FilledButton(style:FilledButton.styleFrom(backgroundColor:ink),onPressed:(){
    final n=double.tryParse(amount.text); if(name.text.trim().isEmpty||n==null||n<=0)return;
    setState(()=>entries.insert(0,Entry(name.text.trim(),category,n,incoming,'Just now',incoming?Icons.south_west_rounded:Icons.receipt_long_rounded)));
    Navigator.pop(ctx);
   },child:const Text('Save entry'))]
  )));
 }
 @override Widget build(BuildContext context) {
  final wide = MediaQuery
      .sizeOf(context)
      .width > 900;
  return Scaffold(body: SafeArea(child: Row(children: [
   if(wide)_sidebar(),
   Expanded(child: Column(children: [
    _header(wide),
    Expanded(child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(wide ? 34 : 18, 18, wide ? 34 : 18, 30),
        child: page == 0 ? _dashboard(wide) : page == 1
            ? _activity()
            : _insights()))
   ]))
  ])),
   floatingActionButton: wide ? null : FloatingActionButton.extended(
    onPressed: addEntry,
    backgroundColor: ink,
    foregroundColor: lime,
    icon: const Icon(Icons.add),
    label: const Text('Add entry'),
   ),
  );
 }
 Widget _sidebar()=>Container(width:245,color:ink,padding:const EdgeInsets.fromLTRB(22,28,18,20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  Row(children:[Container(width:38,height:38,decoration:BoxDecoration(color:lime,borderRadius:BorderRadius.circular(13)),child:const Icon(Icons.waves_rounded,color:ink)),const SizedBox(width:10),const Text('morrow',style:TextStyle(color:Colors.white,fontSize:23,fontWeight:FontWeight.w800,letterSpacing:-1))]),
  const SizedBox(height:52),const Text('YOUR SPACE',style:TextStyle(color:Color(0xFF87968E),fontSize:10,fontWeight:FontWeight.w800,letterSpacing:1.7)),const SizedBox(height:14),
  _nav('Overview',Icons.grid_view_rounded,0),_nav('Activity',Icons.receipt_long_rounded,1),_nav('Insights',Icons.insights_rounded,2),const Spacer(),
  Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:const Color(0xFF2C4037),borderRadius:BorderRadius.circular(18)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(Icons.auto_awesome_rounded,color:lime),SizedBox(height:12),Text('Progress over perfection.',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w700)),SizedBox(height:5),Text('Little choices add up to big changes.',style:TextStyle(color:Color(0xFFB4C1B9),fontSize:12,height:1.4))])),
  const SizedBox(height:20),const Row(children:[CircleAvatar(backgroundColor:Color(0xFFE2EBD9),child:Text('T',style:TextStyle(color:ink,fontWeight:FontWeight.bold))),SizedBox(width:10),Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Trisha V',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w700)),Text('Personal account',style:TextStyle(color:Color(0xFFA5B1AA),fontSize:11))])])
 ]));
 Widget _nav(String label,IconData icon,int i)=>Padding(padding:const EdgeInsets.only(bottom:7),child:InkWell(borderRadius:BorderRadius.circular(13),onTap:()=>setState(()=>page=i),child:AnimatedContainer(duration:const Duration(milliseconds:220),padding:const EdgeInsets.symmetric(horizontal:13,vertical:13),decoration:BoxDecoration(color:page==i?const Color(0xFF344A3F):Colors.transparent,borderRadius:BorderRadius.circular(13)),child:Row(children:[Icon(icon,size:19,color:page==i?lime:const Color(0xFFA7B3AB)),const SizedBox(width:13),Text(label,style:TextStyle(color:page==i?Colors.white:const Color(0xFFB7C1BB),fontWeight:page==i?FontWeight.w700:FontWeight.w500))]))));
 Widget _header(bool wide)=>Padding(padding:EdgeInsets.fromLTRB(wide?34:18,wide?25:16,wide?34:18,8),child:Row(children:[
  if(!wide)Container(width:35,height:35,decoration:BoxDecoration(color:ink,borderRadius:BorderRadius.circular(11)),child:const Icon(Icons.waves_rounded,color:lime)),
  if(!wide)const SizedBox(width:10),
  Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   Text(page==0?'Your money, in rhythm.':page==1?'The little details.':'See the bigger picture.',style:TextStyle(fontSize:wide?24:18,fontWeight:FontWeight.w800,color:ink,letterSpacing:-.6)),
   const Text('Friday, November 13, 2026',style:TextStyle(color:muted,fontSize:11))
  ])),
  if(wide)FilledButton.icon(onPressed:addEntry,style:FilledButton.styleFrom(backgroundColor:ink,foregroundColor:lime,padding:const EdgeInsets.symmetric(horizontal:17,vertical:15)),icon:const Icon(Icons.add,size:18),label:const Text('Add transaction')),
  if(!wide)IconButton(onPressed:addEntry,icon:const Icon(Icons.add_circle_rounded,color:forest,size:29)),
  const SizedBox(width:7),const CircleAvatar(radius:17,backgroundColor:Color(0xFFE2EBD9),child:Icon(Icons.notifications_none_rounded,color:ink,size:19))
 ]));
 Widget _dashboard(bool wide)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  _balance(),
  const SizedBox(height:15),
  GridView.count(crossAxisCount:wide?3:2,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisSpacing:13,mainAxisSpacing:13,childAspectRatio:wide?1.6:1.3,children:[
   _stat('Money in',cash(income),Icons.south_west_rounded,forest,'↑ 12.8% this month'),
   _stat('Money out',cash(spent),Icons.north_east_rounded,coral,'↓ 4.2% vs last month'),
   if(wide)_stat('Savings rate','${income==0?0:((income-spent)/income*100).clamp(0,100).toStringAsFixed(0)}%',Icons.savings_rounded,ink,'Building momentum')
  ]),
  if(!wide)...[const SizedBox(height:13),_stat('Savings rate','${income==0?0:((income-spent)/income*100).clamp(0,100).toStringAsFixed(0)}%',Icons.savings_rounded,ink,'Building momentum')],
  const SizedBox(height:22),
  if(wide)Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(flex:3,child:_chart()),const SizedBox(width:14),Expanded(flex:2,child:_spending())])
  else ...[_chart(),const SizedBox(height:14),_spending()],
  const SizedBox(height:22),_section('Recent activity','See all',()=>setState(()=>page=1)),const SizedBox(height:9),_list(entries.take(4).toList())
 ]);
 Widget _balance()=>Container(width:double.infinity,padding:const EdgeInsets.all(24),decoration:BoxDecoration(borderRadius:BorderRadius.circular(25),gradient:const LinearGradient(colors:[Color(0xFF172923),Color(0xFF315B49)],begin:Alignment.topLeft,end:Alignment.bottomRight),boxShadow:[BoxShadow(color:ink.withOpacity(.13),blurRadius:22,offset:const Offset(0,10))]),child:Stack(children:[
  Positioned(right:-20,top:-48,child:Container(width:175,height:175,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:Colors.white.withOpacity(.07),width:25)))),
  Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   Row(children:[const Text('TOTAL AVAILABLE',style:TextStyle(color:Color(0xFFBDCCC2),fontSize:10,fontWeight:FontWeight.w800,letterSpacing:1.7)),const Spacer(),Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),decoration:BoxDecoration(color:lime.withOpacity(.16),borderRadius:BorderRadius.circular(30)),child:const Row(children:[Icon(Icons.trending_up,color:lime,size:14),SizedBox(width:5),Text('Looking good',style:TextStyle(color:lime,fontSize:10,fontWeight:FontWeight.bold))]))]),
   const SizedBox(height:14),TweenAnimationBuilder<double>(tween:Tween(begin:0,end:income-spent),duration:const Duration(milliseconds:1000),curve:Curves.easeOutCubic,builder:(c,v,_)=>Text(cash(v),style:const TextStyle(color:Colors.white,fontSize:34,fontWeight:FontWeight.w800,letterSpacing:-1.5))),
   const SizedBox(height:6),const Text('You’re in control of where it goes.',style:TextStyle(color:Color(0xFFBDCCC2),fontSize:12)),
   const SizedBox(height:22),Row(children:[_balanceLabel('INCOME',cash(income),lime),const SizedBox(width:28),_balanceLabel('SPENDING',cash(spent),coral)])
  ])
 ]));
 Widget _balanceLabel(String title,String value,Color color)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Container(width:6,height:6,decoration:BoxDecoration(color:color,shape:BoxShape.circle)),const SizedBox(width:6),Text(title,style:const TextStyle(color:Color(0xFFBDCCC2),fontSize:9,letterSpacing:1.1,fontWeight:FontWeight.bold))]),const SizedBox(height:5),Text(value,style:const TextStyle(color:Colors.white,fontSize:15,fontWeight:FontWeight.w700))]);
 Widget _stat(String title,String value,IconData icon,Color color,String note)=>Container(padding:const EdgeInsets.all(15),decoration:card(),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
  Row(children:[Container(padding:const EdgeInsets.all(8),decoration:BoxDecoration(color:color.withOpacity(.1),borderRadius:BorderRadius.circular(10)),child:Icon(icon,color:color,size:17)),const Spacer(),const Icon(Icons.more_horiz,color:muted,size:18)]),
  Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(color:muted,fontSize:11)),const SizedBox(height:3),FittedBox(child:Text(value,style:const TextStyle(color:ink,fontSize:23,fontWeight:FontWeight.w800,letterSpacing:-.6))),const SizedBox(height:3),Text(note,style:TextStyle(color:color,fontSize:9,fontWeight:FontWeight.w600),maxLines:1,overflow:TextOverflow.ellipsis)])
 ]));
 Widget _chart()=>Container(padding:const EdgeInsets.all(19),decoration:card(),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  Row(children:[const Expanded(child:Text('Cash flow',style:TextStyle(color:ink,fontSize:16,fontWeight:FontWeight.w800))),Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:7),decoration:BoxDecoration(color:paper,borderRadius:BorderRadius.circular(9)),child:const Text('This week  ⌄',style:TextStyle(color:muted,fontSize:10,fontWeight:FontWeight.w600)))]),
  const SizedBox(height:5),const Text('A weekly snapshot of your money',style:TextStyle(color:muted,fontSize:11)),const SizedBox(height:19),
  SizedBox(height:140,child:CustomPaint(painter:FlowPainter(),child:const SizedBox.expand())),const SizedBox(height:8),
  const Row(mainAxisAlignment:MainAxisAlignment.center,children:[LegendDot(forest,'Income'),SizedBox(width:20),LegendDot(coral,'Expenses')])
 ]));
 Widget _spending()=>Container(padding:const EdgeInsets.all(19),decoration:card(),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  const Text('Where it goes',style:TextStyle(color:ink,fontSize:16,fontWeight:FontWeight.w800)),const SizedBox(height:5),const Text('Your spending mix',style:TextStyle(color:muted,fontSize:11)),const SizedBox(height:17),
  Row(children:[SizedBox(width:108,height:108,child:CustomPaint(painter:DonutPainter())),const SizedBox(width:16),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[SpendLine('Groceries','38%',forest),SpendLine('Lifestyle','26%',coral),SpendLine('Transport','18%',Color(0xFFB8C7A8)),SpendLine('Other','18%',Color(0xFFE2D8C9))]))])
 ]));
 Widget _section(String title,String action,VoidCallback fn)=>Row(children:[Expanded(child:Text(title,style:const TextStyle(color:ink,fontSize:17,fontWeight:FontWeight.w800))),TextButton(onPressed:fn,child:Text(action,style:const TextStyle(color:forest,fontWeight:FontWeight.bold,fontSize:12)))]);
 Widget _list(List<Entry> data)=>Container(decoration:card(),child:Column(children:data.asMap().entries.map((item)=>Column(children:[
  _entryRow(item.value),if(item.key!=data.length-1)const Divider(height:1,indent:64,endIndent:17,color:Color(0xFFF0F1EC))
 ])).toList()));
 Widget _entryRow(Entry e)=>Padding(padding:const EdgeInsets.symmetric(horizontal:15,vertical:13),child:Row(children:[
  Container(width:39,height:39,decoration:BoxDecoration(color:(e.income?forest:coral).withOpacity(.11),borderRadius:BorderRadius.circular(13)),child:Icon(e.icon,color:e.income?forest:coral,size:18)),
  const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(e.name,style:const TextStyle(color:ink,fontWeight:FontWeight.w700,fontSize:12)),const SizedBox(height:4),Text('${e.category} · ${e.when}',style:const TextStyle(color:muted,fontSize:10))])),
  Text('${e.income?'+':'−'}${cash(e.amount)}',style:TextStyle(color:e.income?forest:ink,fontWeight:FontWeight.w800,fontSize:12))
 ]));
 Widget _activity()=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  _section('All activity','Add entry',addEntry),const SizedBox(height:12),
  Wrap(spacing:8,runSpacing:8,children:['All','Income','Groceries','Food & drink','Transport','Entertainment'].map((f)=>ChoiceChip(label:Text(f),selected:filter==f,onSelected:(_)=>setState(()=>filter=f),selectedColor:lime,backgroundColor:Colors.white,side:BorderSide(color:filter==f?lime:const Color(0xFFE5EAE2)),labelStyle:const TextStyle(color:ink,fontSize:11))).toList()),
  const SizedBox(height:15),_list(entries.where((e)=>filter=='All'||(filter=='Income'?e.income:e.category==filter)).toList())
 ]);
 Widget _insights()=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  const Text('Your money patterns',style:TextStyle(color:ink,fontSize:22,fontWeight:FontWeight.w800)),const SizedBox(height:6),const Text('Small insights for confident choices.',style:TextStyle(color:muted,fontSize:12)),const SizedBox(height:18),_chart(),const SizedBox(height:15),_spending(),const SizedBox(height:15),
  Container(padding:const EdgeInsets.all(19),decoration:BoxDecoration(color:lime,borderRadius:BorderRadius.circular(20)),child:const Row(children:[Icon(Icons.lightbulb_outline_rounded,color:ink,size:27),SizedBox(width:13),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('A habit worth keeping',style:TextStyle(color:ink,fontWeight:FontWeight.w800)),SizedBox(height:4),Text('Review subscriptions once a month. Tiny changes can make room for bigger plans.',style:TextStyle(color:ink,fontSize:12,height:1.4))]))]))
 ]);
}
class LegendDot extends StatelessWidget {const LegendDot(this.color,this.label,{super.key});final Color color;final String label;@override Widget build(BuildContext c)=>Row(children:[Container(width:7,height:7,decoration:BoxDecoration(color:color,shape:BoxShape.circle)),const SizedBox(width:6),Text(label,style:const TextStyle(color:muted,fontSize:10))]);}
class SpendLine extends StatelessWidget {const SpendLine(this.name,this.percent,this.color,{super.key});final String name,percent;final Color color;@override Widget build(BuildContext c)=>Padding(padding:const EdgeInsets.only(bottom:9),child:Row(children:[Container(width:7,height:7,decoration:BoxDecoration(color:color,shape:BoxShape.circle)),const SizedBox(width:6),Expanded(child:Text(name,style:const TextStyle(color:muted,fontSize:10))),Text(percent,style:const TextStyle(color:ink,fontWeight:FontWeight.bold,fontSize:10))]));}
class FlowPainter extends CustomPainter {
 @override void paint(Canvas canvas,Size size){
  final grid=Paint()..color=const Color(0xFFEEF0EA)..strokeWidth=1;for(int i=0;i<4;i++){final y=i*size.height/3;canvas.drawLine(Offset(0,y),Offset(size.width,y),grid);}
  final p=Paint()..style=PaintingStyle.stroke..strokeWidth=2.8..strokeCap=StrokeCap.round;
  Path curve(List<double> values){final dx=size.width/(values.length-1);final path=Path()..moveTo(0,values[0]*size.height);for(int i=1;i<values.length;i++){final x=(i-1)*dx, nx=i*dx, mid=(x+nx)/2;path.cubicTo(mid,values[i-1]*size.height,mid,values[i]*size.height,nx,values[i]*size.height);}return path;}
  p.color=forest;canvas.drawPath(curve([.72,.57,.68,.35,.48,.28,.4]),p);p.color=coral;canvas.drawPath(curve([.83,.72,.78,.61,.72,.55,.67]),p);
  final tp=TextPainter(textDirection:TextDirection.ltr);const days=['MON','TUE','WED','THU','FRI','SAT','SUN'];for(int i=0;i<7;i++){tp.text=TextSpan(text:days[i],style:const TextStyle(color:muted,fontSize:8,fontWeight:FontWeight.w600));tp.layout();tp.paint(canvas,Offset(i*size.width/6-tp.width/2,size.height-1));}
 }
 @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
}
class DonutPainter extends CustomPainter {
 @override void paint(Canvas canvas,Size size){final rect=Offset.zero&size;final p=Paint()..style=PaintingStyle.stroke..strokeWidth=14..strokeCap=StrokeCap.round;final colors=[forest,coral,const Color(0xFFB8C7A8),const Color(0xFFE2D8C9)],values=[.38,.26,.18,.18];double start=-math.pi/2;for(int i=0;i<4;i++){p.color=colors[i];canvas.drawArc(rect.deflate(9),start,values[i]*math.pi*2-.07,false,p);start+=values[i]*math.pi*2;}}
 @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
}
