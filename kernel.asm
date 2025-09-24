
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 00 51 11 80       	mov    $0x80115100,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 99 38 10 80       	mov    $0x80103899,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 88 85 10 80       	push   $0x80108588
80100042:	68 a0 b5 10 80       	push   $0x8010b5a0
80100047:	e8 f4 4f 00 00       	call   80105040 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 b0 f4 10 80 a4 	movl   $0x8010f4a4,0x8010f4b0
80100056:	f4 10 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 b4 f4 10 80 a4 	movl   $0x8010f4a4,0x8010f4b4
80100060:	f4 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 d4 b5 10 80 	movl   $0x8010b5d4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 b4 f4 10 80    	mov    0x8010f4b4,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c a4 f4 10 80 	movl   $0x8010f4a4,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 b4 f4 10 80       	mov    0x8010f4b4,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 b4 f4 10 80       	mov    %eax,0x8010f4b4
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 a4 f4 10 80       	mov    $0x8010f4a4,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
  }
}
801000b0:	90                   	nop
801000b1:	90                   	nop
801000b2:	c9                   	leave
801000b3:	c3                   	ret

801000b4 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b4:	55                   	push   %ebp
801000b5:	89 e5                	mov    %esp,%ebp
801000b7:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000ba:	83 ec 0c             	sub    $0xc,%esp
801000bd:	68 a0 b5 10 80       	push   $0x8010b5a0
801000c2:	e8 9b 4f 00 00       	call   80105062 <acquire>
801000c7:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000ca:	a1 b4 f4 10 80       	mov    0x8010f4b4,%eax
801000cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d2:	eb 67                	jmp    8010013b <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d7:	8b 40 04             	mov    0x4(%eax),%eax
801000da:	39 45 08             	cmp    %eax,0x8(%ebp)
801000dd:	75 53                	jne    80100132 <bget+0x7e>
801000df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e2:	8b 40 08             	mov    0x8(%eax),%eax
801000e5:	39 45 0c             	cmp    %eax,0xc(%ebp)
801000e8:	75 48                	jne    80100132 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ed:	8b 00                	mov    (%eax),%eax
801000ef:	83 e0 01             	and    $0x1,%eax
801000f2:	85 c0                	test   %eax,%eax
801000f4:	75 27                	jne    8010011d <bget+0x69>
        b->flags |= B_BUSY;
801000f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f9:	8b 00                	mov    (%eax),%eax
801000fb:	83 c8 01             	or     $0x1,%eax
801000fe:	89 c2                	mov    %eax,%edx
80100100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100103:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100105:	83 ec 0c             	sub    $0xc,%esp
80100108:	68 a0 b5 10 80       	push   $0x8010b5a0
8010010d:	e8 b7 4f 00 00       	call   801050c9 <release>
80100112:	83 c4 10             	add    $0x10,%esp
        return b;
80100115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100118:	e9 98 00 00 00       	jmp    801001b5 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011d:	83 ec 08             	sub    $0x8,%esp
80100120:	68 a0 b5 10 80       	push   $0x8010b5a0
80100125:	ff 75 f4             	push   -0xc(%ebp)
80100128:	e8 3a 4c 00 00       	call   80104d67 <sleep>
8010012d:	83 c4 10             	add    $0x10,%esp
      goto loop;
80100130:	eb 98                	jmp    801000ca <bget+0x16>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	8b 40 10             	mov    0x10(%eax),%eax
80100138:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013b:	81 7d f4 a4 f4 10 80 	cmpl   $0x8010f4a4,-0xc(%ebp)
80100142:	75 90                	jne    801000d4 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100144:	a1 b0 f4 10 80       	mov    0x8010f4b0,%eax
80100149:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014c:	eb 51                	jmp    8010019f <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 01             	and    $0x1,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 3c                	jne    80100196 <bget+0xe2>
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 00                	mov    (%eax),%eax
8010015f:	83 e0 04             	and    $0x4,%eax
80100162:	85 c0                	test   %eax,%eax
80100164:	75 30                	jne    80100196 <bget+0xe2>
      b->dev = dev;
80100166:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100169:	8b 55 08             	mov    0x8(%ebp),%edx
8010016c:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100172:	8b 55 0c             	mov    0xc(%ebp),%edx
80100175:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100181:	83 ec 0c             	sub    $0xc,%esp
80100184:	68 a0 b5 10 80       	push   $0x8010b5a0
80100189:	e8 3b 4f 00 00       	call   801050c9 <release>
8010018e:	83 c4 10             	add    $0x10,%esp
      return b;
80100191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100194:	eb 1f                	jmp    801001b5 <bget+0x101>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100199:	8b 40 0c             	mov    0xc(%eax),%eax
8010019c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019f:	81 7d f4 a4 f4 10 80 	cmpl   $0x8010f4a4,-0xc(%ebp)
801001a6:	75 a6                	jne    8010014e <bget+0x9a>
    }
  }
  panic("bget: no buffers");
801001a8:	83 ec 0c             	sub    $0xc,%esp
801001ab:	68 8f 85 10 80       	push   $0x8010858f
801001b0:	e8 c4 03 00 00       	call   80100579 <panic>
}
801001b5:	c9                   	leave
801001b6:	c3                   	ret

801001b7 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b7:	55                   	push   %ebp
801001b8:	89 e5                	mov    %esp,%ebp
801001ba:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bd:	83 ec 08             	sub    $0x8,%esp
801001c0:	ff 75 0c             	push   0xc(%ebp)
801001c3:	ff 75 08             	push   0x8(%ebp)
801001c6:	e8 e9 fe ff ff       	call   801000b4 <bget>
801001cb:	83 c4 10             	add    $0x10,%esp
801001ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	8b 00                	mov    (%eax),%eax
801001d6:	83 e0 02             	and    $0x2,%eax
801001d9:	85 c0                	test   %eax,%eax
801001db:	75 0e                	jne    801001eb <bread+0x34>
    iderw(b);
801001dd:	83 ec 0c             	sub    $0xc,%esp
801001e0:	ff 75 f4             	push   -0xc(%ebp)
801001e3:	e8 37 27 00 00       	call   8010291f <iderw>
801001e8:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ee:	c9                   	leave
801001ef:	c3                   	ret

801001f0 <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001f0:	55                   	push   %ebp
801001f1:	89 e5                	mov    %esp,%ebp
801001f3:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f6:	8b 45 08             	mov    0x8(%ebp),%eax
801001f9:	8b 00                	mov    (%eax),%eax
801001fb:	83 e0 01             	and    $0x1,%eax
801001fe:	85 c0                	test   %eax,%eax
80100200:	75 0d                	jne    8010020f <bwrite+0x1f>
    panic("bwrite");
80100202:	83 ec 0c             	sub    $0xc,%esp
80100205:	68 a0 85 10 80       	push   $0x801085a0
8010020a:	e8 6a 03 00 00       	call   80100579 <panic>
  b->flags |= B_DIRTY;
8010020f:	8b 45 08             	mov    0x8(%ebp),%eax
80100212:	8b 00                	mov    (%eax),%eax
80100214:	83 c8 04             	or     $0x4,%eax
80100217:	89 c2                	mov    %eax,%edx
80100219:	8b 45 08             	mov    0x8(%ebp),%eax
8010021c:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021e:	83 ec 0c             	sub    $0xc,%esp
80100221:	ff 75 08             	push   0x8(%ebp)
80100224:	e8 f6 26 00 00       	call   8010291f <iderw>
80100229:	83 c4 10             	add    $0x10,%esp
}
8010022c:	90                   	nop
8010022d:	c9                   	leave
8010022e:	c3                   	ret

8010022f <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022f:	55                   	push   %ebp
80100230:	89 e5                	mov    %esp,%ebp
80100232:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100235:	8b 45 08             	mov    0x8(%ebp),%eax
80100238:	8b 00                	mov    (%eax),%eax
8010023a:	83 e0 01             	and    $0x1,%eax
8010023d:	85 c0                	test   %eax,%eax
8010023f:	75 0d                	jne    8010024e <brelse+0x1f>
    panic("brelse");
80100241:	83 ec 0c             	sub    $0xc,%esp
80100244:	68 a7 85 10 80       	push   $0x801085a7
80100249:	e8 2b 03 00 00       	call   80100579 <panic>

  acquire(&bcache.lock);
8010024e:	83 ec 0c             	sub    $0xc,%esp
80100251:	68 a0 b5 10 80       	push   $0x8010b5a0
80100256:	e8 07 4e 00 00       	call   80105062 <acquire>
8010025b:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025e:	8b 45 08             	mov    0x8(%ebp),%eax
80100261:	8b 40 10             	mov    0x10(%eax),%eax
80100264:	8b 55 08             	mov    0x8(%ebp),%edx
80100267:	8b 52 0c             	mov    0xc(%edx),%edx
8010026a:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	8b 40 0c             	mov    0xc(%eax),%eax
80100273:	8b 55 08             	mov    0x8(%ebp),%edx
80100276:	8b 52 10             	mov    0x10(%edx),%edx
80100279:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027c:	8b 15 b4 f4 10 80    	mov    0x8010f4b4,%edx
80100282:	8b 45 08             	mov    0x8(%ebp),%eax
80100285:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	c7 40 0c a4 f4 10 80 	movl   $0x8010f4a4,0xc(%eax)
  bcache.head.next->prev = b;
80100292:	a1 b4 f4 10 80       	mov    0x8010f4b4,%eax
80100297:	8b 55 08             	mov    0x8(%ebp),%edx
8010029a:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029d:	8b 45 08             	mov    0x8(%ebp),%eax
801002a0:	a3 b4 f4 10 80       	mov    %eax,0x8010f4b4

  b->flags &= ~B_BUSY;
801002a5:	8b 45 08             	mov    0x8(%ebp),%eax
801002a8:	8b 00                	mov    (%eax),%eax
801002aa:	83 e0 fe             	and    $0xfffffffe,%eax
801002ad:	89 c2                	mov    %eax,%edx
801002af:	8b 45 08             	mov    0x8(%ebp),%eax
801002b2:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b4:	83 ec 0c             	sub    $0xc,%esp
801002b7:	ff 75 08             	push   0x8(%ebp)
801002ba:	e8 94 4b 00 00       	call   80104e53 <wakeup>
801002bf:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c2:	83 ec 0c             	sub    $0xc,%esp
801002c5:	68 a0 b5 10 80       	push   $0x8010b5a0
801002ca:	e8 fa 4d 00 00       	call   801050c9 <release>
801002cf:	83 c4 10             	add    $0x10,%esp
}
801002d2:	90                   	nop
801002d3:	c9                   	leave
801002d4:	c3                   	ret

801002d5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d5:	55                   	push   %ebp
801002d6:	89 e5                	mov    %esp,%ebp
801002d8:	83 ec 14             	sub    $0x14,%esp
801002db:	8b 45 08             	mov    0x8(%ebp),%eax
801002de:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e6:	89 c2                	mov    %eax,%edx
801002e8:	ec                   	in     (%dx),%al
801002e9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002ec:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002f0:	c9                   	leave
801002f1:	c3                   	ret

801002f2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f2:	55                   	push   %ebp
801002f3:	89 e5                	mov    %esp,%ebp
801002f5:	83 ec 08             	sub    $0x8,%esp
801002f8:	8b 55 08             	mov    0x8(%ebp),%edx
801002fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fe:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100302:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100305:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100309:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030d:	ee                   	out    %al,(%dx)
}
8010030e:	90                   	nop
8010030f:	c9                   	leave
80100310:	c3                   	ret

80100311 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100311:	55                   	push   %ebp
80100312:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100314:	fa                   	cli
}
80100315:	90                   	nop
80100316:	5d                   	pop    %ebp
80100317:	c3                   	ret

80100318 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100318:	55                   	push   %ebp
80100319:	89 e5                	mov    %esp,%ebp
8010031b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x28>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x28>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2e>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100350:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100353:	ba 00 00 00 00       	mov    $0x0,%edx
80100358:	f7 f1                	div    %ecx
8010035a:	89 d1                	mov    %edx,%ecx
8010035c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010035f:	8d 50 01             	lea    0x1(%eax),%edx
80100362:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100365:	0f b6 91 04 90 10 80 	movzbl -0x7fef6ffc(%ecx),%edx
8010036c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
80100370:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f1                	div    %ecx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x35>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9e>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9e>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 fb 03 00 00       	call   801007ae <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x84>
}
801003c0:	90                   	nop
801003c1:	90                   	nop
801003c2:	c9                   	leave
801003c3:	c3                   	ret

801003c4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c4:	55                   	push   %ebp
801003c5:	89 e5                	mov    %esp,%ebp
801003c7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003ca:	a1 94 f7 10 80       	mov    0x8010f794,%eax
801003cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d6:	74 10                	je     801003e8 <cprintf+0x24>
    acquire(&cons.lock);
801003d8:	83 ec 0c             	sub    $0xc,%esp
801003db:	68 60 f7 10 80       	push   $0x8010f760
801003e0:	e8 7d 4c 00 00       	call   80105062 <acquire>
801003e5:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003e8:	8b 45 08             	mov    0x8(%ebp),%eax
801003eb:	85 c0                	test   %eax,%eax
801003ed:	75 0d                	jne    801003fc <cprintf+0x38>
    panic("null fmt");
801003ef:	83 ec 0c             	sub    $0xc,%esp
801003f2:	68 ae 85 10 80       	push   $0x801085ae
801003f7:	e8 7d 01 00 00       	call   80100579 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fc:	8d 45 0c             	lea    0xc(%ebp),%eax
801003ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100402:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100409:	e9 2f 01 00 00       	jmp    8010053d <cprintf+0x179>
    if(c != '%'){
8010040e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100412:	74 13                	je     80100427 <cprintf+0x63>
      consputc(c);
80100414:	83 ec 0c             	sub    $0xc,%esp
80100417:	ff 75 e4             	push   -0x1c(%ebp)
8010041a:	e8 8f 03 00 00       	call   801007ae <consputc>
8010041f:	83 c4 10             	add    $0x10,%esp
      continue;
80100422:	e9 12 01 00 00       	jmp    80100539 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100427:	8b 55 08             	mov    0x8(%ebp),%edx
8010042a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010042e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100431:	01 d0                	add    %edx,%eax
80100433:	0f b6 00             	movzbl (%eax),%eax
80100436:	0f be c0             	movsbl %al,%eax
80100439:	25 ff 00 00 00       	and    $0xff,%eax
8010043e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100441:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100445:	0f 84 14 01 00 00    	je     8010055f <cprintf+0x19b>
      break;
    switch(c){
8010044b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010044f:	74 5e                	je     801004af <cprintf+0xeb>
80100451:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100455:	0f 8f c2 00 00 00    	jg     8010051d <cprintf+0x159>
8010045b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010045f:	74 6b                	je     801004cc <cprintf+0x108>
80100461:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100465:	0f 8f b2 00 00 00    	jg     8010051d <cprintf+0x159>
8010046b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010046f:	74 3e                	je     801004af <cprintf+0xeb>
80100471:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
80100475:	0f 8f a2 00 00 00    	jg     8010051d <cprintf+0x159>
8010047b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010047f:	0f 84 89 00 00 00    	je     8010050e <cprintf+0x14a>
80100485:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
80100489:	0f 85 8e 00 00 00    	jne    8010051d <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
8010048f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100492:	8d 50 04             	lea    0x4(%eax),%edx
80100495:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100498:	8b 00                	mov    (%eax),%eax
8010049a:	83 ec 04             	sub    $0x4,%esp
8010049d:	6a 01                	push   $0x1
8010049f:	6a 0a                	push   $0xa
801004a1:	50                   	push   %eax
801004a2:	e8 71 fe ff ff       	call   80100318 <printint>
801004a7:	83 c4 10             	add    $0x10,%esp
      break;
801004aa:	e9 8a 00 00 00       	jmp    80100539 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004b2:	8d 50 04             	lea    0x4(%eax),%edx
801004b5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004b8:	8b 00                	mov    (%eax),%eax
801004ba:	83 ec 04             	sub    $0x4,%esp
801004bd:	6a 00                	push   $0x0
801004bf:	6a 10                	push   $0x10
801004c1:	50                   	push   %eax
801004c2:	e8 51 fe ff ff       	call   80100318 <printint>
801004c7:	83 c4 10             	add    $0x10,%esp
      break;
801004ca:	eb 6d                	jmp    80100539 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004cf:	8d 50 04             	lea    0x4(%eax),%edx
801004d2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004d5:	8b 00                	mov    (%eax),%eax
801004d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004da:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004de:	75 22                	jne    80100502 <cprintf+0x13e>
        s = "(null)";
801004e0:	c7 45 ec b7 85 10 80 	movl   $0x801085b7,-0x14(%ebp)
      for(; *s; s++)
801004e7:	eb 19                	jmp    80100502 <cprintf+0x13e>
        consputc(*s);
801004e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004ec:	0f b6 00             	movzbl (%eax),%eax
801004ef:	0f be c0             	movsbl %al,%eax
801004f2:	83 ec 0c             	sub    $0xc,%esp
801004f5:	50                   	push   %eax
801004f6:	e8 b3 02 00 00       	call   801007ae <consputc>
801004fb:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
801004fe:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100502:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100505:	0f b6 00             	movzbl (%eax),%eax
80100508:	84 c0                	test   %al,%al
8010050a:	75 dd                	jne    801004e9 <cprintf+0x125>
      break;
8010050c:	eb 2b                	jmp    80100539 <cprintf+0x175>
    case '%':
      consputc('%');
8010050e:	83 ec 0c             	sub    $0xc,%esp
80100511:	6a 25                	push   $0x25
80100513:	e8 96 02 00 00       	call   801007ae <consputc>
80100518:	83 c4 10             	add    $0x10,%esp
      break;
8010051b:	eb 1c                	jmp    80100539 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010051d:	83 ec 0c             	sub    $0xc,%esp
80100520:	6a 25                	push   $0x25
80100522:	e8 87 02 00 00       	call   801007ae <consputc>
80100527:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010052a:	83 ec 0c             	sub    $0xc,%esp
8010052d:	ff 75 e4             	push   -0x1c(%ebp)
80100530:	e8 79 02 00 00       	call   801007ae <consputc>
80100535:	83 c4 10             	add    $0x10,%esp
      break;
80100538:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100539:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010053d:	8b 55 08             	mov    0x8(%ebp),%edx
80100540:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100543:	01 d0                	add    %edx,%eax
80100545:	0f b6 00             	movzbl (%eax),%eax
80100548:	0f be c0             	movsbl %al,%eax
8010054b:	25 ff 00 00 00       	and    $0xff,%eax
80100550:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100553:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100557:	0f 85 b1 fe ff ff    	jne    8010040e <cprintf+0x4a>
8010055d:	eb 01                	jmp    80100560 <cprintf+0x19c>
      break;
8010055f:	90                   	nop
    }
  }

  if(locking)
80100560:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100564:	74 10                	je     80100576 <cprintf+0x1b2>
    release(&cons.lock);
80100566:	83 ec 0c             	sub    $0xc,%esp
80100569:	68 60 f7 10 80       	push   $0x8010f760
8010056e:	e8 56 4b 00 00       	call   801050c9 <release>
80100573:	83 c4 10             	add    $0x10,%esp
}
80100576:	90                   	nop
80100577:	c9                   	leave
80100578:	c3                   	ret

80100579 <panic>:

void
panic(char *s)
{
80100579:	55                   	push   %ebp
8010057a:	89 e5                	mov    %esp,%ebp
8010057c:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010057f:	e8 8d fd ff ff       	call   80100311 <cli>
  cons.locking = 0;
80100584:	c7 05 94 f7 10 80 00 	movl   $0x0,0x8010f794
8010058b:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010058e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100594:	0f b6 00             	movzbl (%eax),%eax
80100597:	0f b6 c0             	movzbl %al,%eax
8010059a:	83 ec 08             	sub    $0x8,%esp
8010059d:	50                   	push   %eax
8010059e:	68 be 85 10 80       	push   $0x801085be
801005a3:	e8 1c fe ff ff       	call   801003c4 <cprintf>
801005a8:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005ab:	8b 45 08             	mov    0x8(%ebp),%eax
801005ae:	83 ec 0c             	sub    $0xc,%esp
801005b1:	50                   	push   %eax
801005b2:	e8 0d fe ff ff       	call   801003c4 <cprintf>
801005b7:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005ba:	83 ec 0c             	sub    $0xc,%esp
801005bd:	68 cd 85 10 80       	push   $0x801085cd
801005c2:	e8 fd fd ff ff       	call   801003c4 <cprintf>
801005c7:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005ca:	83 ec 08             	sub    $0x8,%esp
801005cd:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005d0:	50                   	push   %eax
801005d1:	8d 45 08             	lea    0x8(%ebp),%eax
801005d4:	50                   	push   %eax
801005d5:	e8 41 4b 00 00       	call   8010511b <getcallerpcs>
801005da:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005e4:	eb 1c                	jmp    80100602 <panic+0x89>
    cprintf(" %p", pcs[i]);
801005e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005e9:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005ed:	83 ec 08             	sub    $0x8,%esp
801005f0:	50                   	push   %eax
801005f1:	68 cf 85 10 80       	push   $0x801085cf
801005f6:	e8 c9 fd ff ff       	call   801003c4 <cprintf>
801005fb:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100602:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100606:	7e de                	jle    801005e6 <panic+0x6d>
  panicked = 1; // freeze other CPU
80100608:	c7 05 4c f7 10 80 01 	movl   $0x1,0x8010f74c
8010060f:	00 00 00 
  for(;;)
80100612:	90                   	nop
80100613:	eb fd                	jmp    80100612 <panic+0x99>

80100615 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100615:	55                   	push   %ebp
80100616:	89 e5                	mov    %esp,%ebp
80100618:	53                   	push   %ebx
80100619:	83 ec 14             	sub    $0x14,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
8010061c:	6a 0e                	push   $0xe
8010061e:	68 d4 03 00 00       	push   $0x3d4
80100623:	e8 ca fc ff ff       	call   801002f2 <outb>
80100628:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
8010062b:	68 d5 03 00 00       	push   $0x3d5
80100630:	e8 a0 fc ff ff       	call   801002d5 <inb>
80100635:	83 c4 04             	add    $0x4,%esp
80100638:	0f b6 c0             	movzbl %al,%eax
8010063b:	c1 e0 08             	shl    $0x8,%eax
8010063e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100641:	6a 0f                	push   $0xf
80100643:	68 d4 03 00 00       	push   $0x3d4
80100648:	e8 a5 fc ff ff       	call   801002f2 <outb>
8010064d:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
80100650:	68 d5 03 00 00       	push   $0x3d5
80100655:	e8 7b fc ff ff       	call   801002d5 <inb>
8010065a:	83 c4 04             	add    $0x4,%esp
8010065d:	0f b6 c0             	movzbl %al,%eax
80100660:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100663:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100667:	75 30                	jne    80100699 <cgaputc+0x84>
    pos += 80 - pos%80;
80100669:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010066c:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100671:	89 c8                	mov    %ecx,%eax
80100673:	f7 ea                	imul   %edx
80100675:	c1 fa 05             	sar    $0x5,%edx
80100678:	89 c8                	mov    %ecx,%eax
8010067a:	c1 f8 1f             	sar    $0x1f,%eax
8010067d:	29 c2                	sub    %eax,%edx
8010067f:	89 d0                	mov    %edx,%eax
80100681:	c1 e0 02             	shl    $0x2,%eax
80100684:	01 d0                	add    %edx,%eax
80100686:	c1 e0 04             	shl    $0x4,%eax
80100689:	29 c1                	sub    %eax,%ecx
8010068b:	89 ca                	mov    %ecx,%edx
8010068d:	b8 50 00 00 00       	mov    $0x50,%eax
80100692:	29 d0                	sub    %edx,%eax
80100694:	01 45 f4             	add    %eax,-0xc(%ebp)
80100697:	eb 38                	jmp    801006d1 <cgaputc+0xbc>
  else if(c == BACKSPACE){
80100699:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006a0:	75 0c                	jne    801006ae <cgaputc+0x99>
    if(pos > 0) --pos;
801006a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006a6:	7e 29                	jle    801006d1 <cgaputc+0xbc>
801006a8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801006ac:	eb 23                	jmp    801006d1 <cgaputc+0xbc>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801006ae:	8b 45 08             	mov    0x8(%ebp),%eax
801006b1:	0f b6 c0             	movzbl %al,%eax
801006b4:	80 cc 07             	or     $0x7,%ah
801006b7:	89 c3                	mov    %eax,%ebx
801006b9:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
801006bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006c2:	8d 50 01             	lea    0x1(%eax),%edx
801006c5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006c8:	01 c0                	add    %eax,%eax
801006ca:	01 c8                	add    %ecx,%eax
801006cc:	89 da                	mov    %ebx,%edx
801006ce:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006d5:	78 09                	js     801006e0 <cgaputc+0xcb>
801006d7:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006de:	7e 0d                	jle    801006ed <cgaputc+0xd8>
    panic("pos under/overflow");
801006e0:	83 ec 0c             	sub    $0xc,%esp
801006e3:	68 d3 85 10 80       	push   $0x801085d3
801006e8:	e8 8c fe ff ff       	call   80100579 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006ed:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006f4:	7e 4c                	jle    80100742 <cgaputc+0x12d>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006f6:	a1 00 90 10 80       	mov    0x80109000,%eax
801006fb:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100701:	a1 00 90 10 80       	mov    0x80109000,%eax
80100706:	83 ec 04             	sub    $0x4,%esp
80100709:	68 60 0e 00 00       	push   $0xe60
8010070e:	52                   	push   %edx
8010070f:	50                   	push   %eax
80100710:	e8 70 4c 00 00       	call   80105385 <memmove>
80100715:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
80100718:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
8010071c:	b8 80 07 00 00       	mov    $0x780,%eax
80100721:	2b 45 f4             	sub    -0xc(%ebp),%eax
80100724:	8d 14 00             	lea    (%eax,%eax,1),%edx
80100727:	a1 00 90 10 80       	mov    0x80109000,%eax
8010072c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010072f:	01 c9                	add    %ecx,%ecx
80100731:	01 c8                	add    %ecx,%eax
80100733:	83 ec 04             	sub    $0x4,%esp
80100736:	52                   	push   %edx
80100737:	6a 00                	push   $0x0
80100739:	50                   	push   %eax
8010073a:	e8 87 4b 00 00       	call   801052c6 <memset>
8010073f:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
80100742:	83 ec 08             	sub    $0x8,%esp
80100745:	6a 0e                	push   $0xe
80100747:	68 d4 03 00 00       	push   $0x3d4
8010074c:	e8 a1 fb ff ff       	call   801002f2 <outb>
80100751:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
80100754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100757:	c1 f8 08             	sar    $0x8,%eax
8010075a:	0f b6 c0             	movzbl %al,%eax
8010075d:	83 ec 08             	sub    $0x8,%esp
80100760:	50                   	push   %eax
80100761:	68 d5 03 00 00       	push   $0x3d5
80100766:	e8 87 fb ff ff       	call   801002f2 <outb>
8010076b:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
8010076e:	83 ec 08             	sub    $0x8,%esp
80100771:	6a 0f                	push   $0xf
80100773:	68 d4 03 00 00       	push   $0x3d4
80100778:	e8 75 fb ff ff       	call   801002f2 <outb>
8010077d:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100780:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100783:	0f b6 c0             	movzbl %al,%eax
80100786:	83 ec 08             	sub    $0x8,%esp
80100789:	50                   	push   %eax
8010078a:	68 d5 03 00 00       	push   $0x3d5
8010078f:	e8 5e fb ff ff       	call   801002f2 <outb>
80100794:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100797:	a1 00 90 10 80       	mov    0x80109000,%eax
8010079c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010079f:	01 d2                	add    %edx,%edx
801007a1:	01 d0                	add    %edx,%eax
801007a3:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801007a8:	90                   	nop
801007a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801007ac:	c9                   	leave
801007ad:	c3                   	ret

801007ae <consputc>:

void
consputc(int c)
{
801007ae:	55                   	push   %ebp
801007af:	89 e5                	mov    %esp,%ebp
801007b1:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
801007b4:	a1 4c f7 10 80       	mov    0x8010f74c,%eax
801007b9:	85 c0                	test   %eax,%eax
801007bb:	74 08                	je     801007c5 <consputc+0x17>
    cli();
801007bd:	e8 4f fb ff ff       	call   80100311 <cli>
    for(;;)
801007c2:	90                   	nop
801007c3:	eb fd                	jmp    801007c2 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
801007c5:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007cc:	75 29                	jne    801007f7 <consputc+0x49>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007ce:	83 ec 0c             	sub    $0xc,%esp
801007d1:	6a 08                	push   $0x8
801007d3:	e8 3a 64 00 00       	call   80106c12 <uartputc>
801007d8:	83 c4 10             	add    $0x10,%esp
801007db:	83 ec 0c             	sub    $0xc,%esp
801007de:	6a 20                	push   $0x20
801007e0:	e8 2d 64 00 00       	call   80106c12 <uartputc>
801007e5:	83 c4 10             	add    $0x10,%esp
801007e8:	83 ec 0c             	sub    $0xc,%esp
801007eb:	6a 08                	push   $0x8
801007ed:	e8 20 64 00 00       	call   80106c12 <uartputc>
801007f2:	83 c4 10             	add    $0x10,%esp
801007f5:	eb 0e                	jmp    80100805 <consputc+0x57>
  } else
    uartputc(c);
801007f7:	83 ec 0c             	sub    $0xc,%esp
801007fa:	ff 75 08             	push   0x8(%ebp)
801007fd:	e8 10 64 00 00       	call   80106c12 <uartputc>
80100802:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
80100805:	83 ec 0c             	sub    $0xc,%esp
80100808:	ff 75 08             	push   0x8(%ebp)
8010080b:	e8 05 fe ff ff       	call   80100615 <cgaputc>
80100810:	83 c4 10             	add    $0x10,%esp
}
80100813:	90                   	nop
80100814:	c9                   	leave
80100815:	c3                   	ret

80100816 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
80100816:	55                   	push   %ebp
80100817:	89 e5                	mov    %esp,%ebp
80100819:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
8010081c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100823:	83 ec 0c             	sub    $0xc,%esp
80100826:	68 60 f7 10 80       	push   $0x8010f760
8010082b:	e8 32 48 00 00       	call   80105062 <acquire>
80100830:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100833:	e9 58 01 00 00       	jmp    80100990 <consoleintr+0x17a>
    switch(c){
80100838:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010083c:	0f 84 81 00 00 00    	je     801008c3 <consoleintr+0xad>
80100842:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100846:	0f 8f ac 00 00 00    	jg     801008f8 <consoleintr+0xe2>
8010084c:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100850:	74 43                	je     80100895 <consoleintr+0x7f>
80100852:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100856:	0f 8f 9c 00 00 00    	jg     801008f8 <consoleintr+0xe2>
8010085c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100860:	74 61                	je     801008c3 <consoleintr+0xad>
80100862:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100866:	0f 85 8c 00 00 00    	jne    801008f8 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
8010086c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100873:	e9 18 01 00 00       	jmp    80100990 <consoleintr+0x17a>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100878:	a1 48 f7 10 80       	mov    0x8010f748,%eax
8010087d:	83 e8 01             	sub    $0x1,%eax
80100880:	a3 48 f7 10 80       	mov    %eax,0x8010f748
        consputc(BACKSPACE);
80100885:	83 ec 0c             	sub    $0xc,%esp
80100888:	68 00 01 00 00       	push   $0x100
8010088d:	e8 1c ff ff ff       	call   801007ae <consputc>
80100892:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100895:	8b 15 48 f7 10 80    	mov    0x8010f748,%edx
8010089b:	a1 44 f7 10 80       	mov    0x8010f744,%eax
801008a0:	39 c2                	cmp    %eax,%edx
801008a2:	0f 84 e1 00 00 00    	je     80100989 <consoleintr+0x173>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008a8:	a1 48 f7 10 80       	mov    0x8010f748,%eax
801008ad:	83 e8 01             	sub    $0x1,%eax
801008b0:	83 e0 7f             	and    $0x7f,%eax
801008b3:	0f b6 80 c0 f6 10 80 	movzbl -0x7fef0940(%eax),%eax
      while(input.e != input.w &&
801008ba:	3c 0a                	cmp    $0xa,%al
801008bc:	75 ba                	jne    80100878 <consoleintr+0x62>
      }
      break;
801008be:	e9 c6 00 00 00       	jmp    80100989 <consoleintr+0x173>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008c3:	8b 15 48 f7 10 80    	mov    0x8010f748,%edx
801008c9:	a1 44 f7 10 80       	mov    0x8010f744,%eax
801008ce:	39 c2                	cmp    %eax,%edx
801008d0:	0f 84 b6 00 00 00    	je     8010098c <consoleintr+0x176>
        input.e--;
801008d6:	a1 48 f7 10 80       	mov    0x8010f748,%eax
801008db:	83 e8 01             	sub    $0x1,%eax
801008de:	a3 48 f7 10 80       	mov    %eax,0x8010f748
        consputc(BACKSPACE);
801008e3:	83 ec 0c             	sub    $0xc,%esp
801008e6:	68 00 01 00 00       	push   $0x100
801008eb:	e8 be fe ff ff       	call   801007ae <consputc>
801008f0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008f3:	e9 94 00 00 00       	jmp    8010098c <consoleintr+0x176>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008fc:	0f 84 8d 00 00 00    	je     8010098f <consoleintr+0x179>
80100902:	8b 15 48 f7 10 80    	mov    0x8010f748,%edx
80100908:	a1 40 f7 10 80       	mov    0x8010f740,%eax
8010090d:	29 c2                	sub    %eax,%edx
8010090f:	83 fa 7f             	cmp    $0x7f,%edx
80100912:	77 7b                	ja     8010098f <consoleintr+0x179>
        c = (c == '\r') ? '\n' : c;
80100914:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100918:	74 05                	je     8010091f <consoleintr+0x109>
8010091a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010091d:	eb 05                	jmp    80100924 <consoleintr+0x10e>
8010091f:	b8 0a 00 00 00       	mov    $0xa,%eax
80100924:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100927:	a1 48 f7 10 80       	mov    0x8010f748,%eax
8010092c:	8d 50 01             	lea    0x1(%eax),%edx
8010092f:	89 15 48 f7 10 80    	mov    %edx,0x8010f748
80100935:	83 e0 7f             	and    $0x7f,%eax
80100938:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010093b:	88 90 c0 f6 10 80    	mov    %dl,-0x7fef0940(%eax)
        consputc(c);
80100941:	83 ec 0c             	sub    $0xc,%esp
80100944:	ff 75 f0             	push   -0x10(%ebp)
80100947:	e8 62 fe ff ff       	call   801007ae <consputc>
8010094c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010094f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100953:	74 18                	je     8010096d <consoleintr+0x157>
80100955:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100959:	74 12                	je     8010096d <consoleintr+0x157>
8010095b:	8b 15 48 f7 10 80    	mov    0x8010f748,%edx
80100961:	a1 40 f7 10 80       	mov    0x8010f740,%eax
80100966:	83 e8 80             	sub    $0xffffff80,%eax
80100969:	39 c2                	cmp    %eax,%edx
8010096b:	75 22                	jne    8010098f <consoleintr+0x179>
          input.w = input.e;
8010096d:	a1 48 f7 10 80       	mov    0x8010f748,%eax
80100972:	a3 44 f7 10 80       	mov    %eax,0x8010f744
          wakeup(&input.r);
80100977:	83 ec 0c             	sub    $0xc,%esp
8010097a:	68 40 f7 10 80       	push   $0x8010f740
8010097f:	e8 cf 44 00 00       	call   80104e53 <wakeup>
80100984:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100987:	eb 06                	jmp    8010098f <consoleintr+0x179>
      break;
80100989:	90                   	nop
8010098a:	eb 04                	jmp    80100990 <consoleintr+0x17a>
      break;
8010098c:	90                   	nop
8010098d:	eb 01                	jmp    80100990 <consoleintr+0x17a>
      break;
8010098f:	90                   	nop
  while((c = getc()) >= 0){
80100990:	8b 45 08             	mov    0x8(%ebp),%eax
80100993:	ff d0                	call   *%eax
80100995:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100998:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010099c:	0f 89 96 fe ff ff    	jns    80100838 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
801009a2:	83 ec 0c             	sub    $0xc,%esp
801009a5:	68 60 f7 10 80       	push   $0x8010f760
801009aa:	e8 1a 47 00 00       	call   801050c9 <release>
801009af:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009b6:	74 05                	je     801009bd <consoleintr+0x1a7>
    procdump();  // now call procdump() wo. cons.lock held
801009b8:	e8 51 45 00 00       	call   80104f0e <procdump>
  }
}
801009bd:	90                   	nop
801009be:	c9                   	leave
801009bf:	c3                   	ret

801009c0 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009c0:	55                   	push   %ebp
801009c1:	89 e5                	mov    %esp,%ebp
801009c3:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009c6:	83 ec 0c             	sub    $0xc,%esp
801009c9:	ff 75 08             	push   0x8(%ebp)
801009cc:	e8 16 11 00 00       	call   80101ae7 <iunlock>
801009d1:	83 c4 10             	add    $0x10,%esp
  target = n;
801009d4:	8b 45 10             	mov    0x10(%ebp),%eax
801009d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009da:	83 ec 0c             	sub    $0xc,%esp
801009dd:	68 60 f7 10 80       	push   $0x8010f760
801009e2:	e8 7b 46 00 00       	call   80105062 <acquire>
801009e7:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009ea:	e9 ac 00 00 00       	jmp    80100a9b <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
801009ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801009f5:	8b 40 24             	mov    0x24(%eax),%eax
801009f8:	85 c0                	test   %eax,%eax
801009fa:	74 28                	je     80100a24 <consoleread+0x64>
        release(&cons.lock);
801009fc:	83 ec 0c             	sub    $0xc,%esp
801009ff:	68 60 f7 10 80       	push   $0x8010f760
80100a04:	e8 c0 46 00 00       	call   801050c9 <release>
80100a09:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a0c:	83 ec 0c             	sub    $0xc,%esp
80100a0f:	ff 75 08             	push   0x8(%ebp)
80100a12:	e8 72 0f 00 00       	call   80101989 <ilock>
80100a17:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a1f:	e9 ab 00 00 00       	jmp    80100acf <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
80100a24:	83 ec 08             	sub    $0x8,%esp
80100a27:	68 60 f7 10 80       	push   $0x8010f760
80100a2c:	68 40 f7 10 80       	push   $0x8010f740
80100a31:	e8 31 43 00 00       	call   80104d67 <sleep>
80100a36:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a39:	8b 15 40 f7 10 80    	mov    0x8010f740,%edx
80100a3f:	a1 44 f7 10 80       	mov    0x8010f744,%eax
80100a44:	39 c2                	cmp    %eax,%edx
80100a46:	74 a7                	je     801009ef <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a48:	a1 40 f7 10 80       	mov    0x8010f740,%eax
80100a4d:	8d 50 01             	lea    0x1(%eax),%edx
80100a50:	89 15 40 f7 10 80    	mov    %edx,0x8010f740
80100a56:	83 e0 7f             	and    $0x7f,%eax
80100a59:	0f b6 80 c0 f6 10 80 	movzbl -0x7fef0940(%eax),%eax
80100a60:	0f be c0             	movsbl %al,%eax
80100a63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a66:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a6a:	75 17                	jne    80100a83 <consoleread+0xc3>
      if(n < target){
80100a6c:	8b 45 10             	mov    0x10(%ebp),%eax
80100a6f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a72:	73 2f                	jae    80100aa3 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a74:	a1 40 f7 10 80       	mov    0x8010f740,%eax
80100a79:	83 e8 01             	sub    $0x1,%eax
80100a7c:	a3 40 f7 10 80       	mov    %eax,0x8010f740
      }
      break;
80100a81:	eb 20                	jmp    80100aa3 <consoleread+0xe3>
    }
    *dst++ = c;
80100a83:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a86:	8d 50 01             	lea    0x1(%eax),%edx
80100a89:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a8c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a8f:	88 10                	mov    %dl,(%eax)
    --n;
80100a91:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a95:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a99:	74 0b                	je     80100aa6 <consoleread+0xe6>
  while(n > 0){
80100a9b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a9f:	7f 98                	jg     80100a39 <consoleread+0x79>
80100aa1:	eb 04                	jmp    80100aa7 <consoleread+0xe7>
      break;
80100aa3:	90                   	nop
80100aa4:	eb 01                	jmp    80100aa7 <consoleread+0xe7>
      break;
80100aa6:	90                   	nop
  }
  release(&cons.lock);
80100aa7:	83 ec 0c             	sub    $0xc,%esp
80100aaa:	68 60 f7 10 80       	push   $0x8010f760
80100aaf:	e8 15 46 00 00       	call   801050c9 <release>
80100ab4:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ab7:	83 ec 0c             	sub    $0xc,%esp
80100aba:	ff 75 08             	push   0x8(%ebp)
80100abd:	e8 c7 0e 00 00       	call   80101989 <ilock>
80100ac2:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100ac5:	8b 45 10             	mov    0x10(%ebp),%eax
80100ac8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100acb:	29 c2                	sub    %eax,%edx
80100acd:	89 d0                	mov    %edx,%eax
}
80100acf:	c9                   	leave
80100ad0:	c3                   	ret

80100ad1 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100ad1:	55                   	push   %ebp
80100ad2:	89 e5                	mov    %esp,%ebp
80100ad4:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100ad7:	83 ec 0c             	sub    $0xc,%esp
80100ada:	ff 75 08             	push   0x8(%ebp)
80100add:	e8 05 10 00 00       	call   80101ae7 <iunlock>
80100ae2:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ae5:	83 ec 0c             	sub    $0xc,%esp
80100ae8:	68 60 f7 10 80       	push   $0x8010f760
80100aed:	e8 70 45 00 00       	call   80105062 <acquire>
80100af2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100af5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100afc:	eb 21                	jmp    80100b1f <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100afe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b01:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b04:	01 d0                	add    %edx,%eax
80100b06:	0f b6 00             	movzbl (%eax),%eax
80100b09:	0f be c0             	movsbl %al,%eax
80100b0c:	0f b6 c0             	movzbl %al,%eax
80100b0f:	83 ec 0c             	sub    $0xc,%esp
80100b12:	50                   	push   %eax
80100b13:	e8 96 fc ff ff       	call   801007ae <consputc>
80100b18:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b1b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b22:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b25:	7c d7                	jl     80100afe <consolewrite+0x2d>
  release(&cons.lock);
80100b27:	83 ec 0c             	sub    $0xc,%esp
80100b2a:	68 60 f7 10 80       	push   $0x8010f760
80100b2f:	e8 95 45 00 00       	call   801050c9 <release>
80100b34:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b37:	83 ec 0c             	sub    $0xc,%esp
80100b3a:	ff 75 08             	push   0x8(%ebp)
80100b3d:	e8 47 0e 00 00       	call   80101989 <ilock>
80100b42:	83 c4 10             	add    $0x10,%esp

  return n;
80100b45:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b48:	c9                   	leave
80100b49:	c3                   	ret

80100b4a <consoleinit>:

void
consoleinit(void)
{
80100b4a:	55                   	push   %ebp
80100b4b:	89 e5                	mov    %esp,%ebp
80100b4d:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b50:	83 ec 08             	sub    $0x8,%esp
80100b53:	68 e6 85 10 80       	push   $0x801085e6
80100b58:	68 60 f7 10 80       	push   $0x8010f760
80100b5d:	e8 de 44 00 00       	call   80105040 <initlock>
80100b62:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b65:	c7 05 ac f7 10 80 d1 	movl   $0x80100ad1,0x8010f7ac
80100b6c:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6f:	c7 05 a8 f7 10 80 c0 	movl   $0x801009c0,0x8010f7a8
80100b76:	09 10 80 
  cons.locking = 1;
80100b79:	c7 05 94 f7 10 80 01 	movl   $0x1,0x8010f794
80100b80:	00 00 00 

  picenable(IRQ_KBD);
80100b83:	83 ec 0c             	sub    $0xc,%esp
80100b86:	6a 01                	push   $0x1
80100b88:	e8 de 33 00 00       	call   80103f6b <picenable>
80100b8d:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b90:	83 ec 08             	sub    $0x8,%esp
80100b93:	6a 00                	push   $0x0
80100b95:	6a 01                	push   $0x1
80100b97:	e8 50 1f 00 00       	call   80102aec <ioapicenable>
80100b9c:	83 c4 10             	add    $0x10,%esp
}
80100b9f:	90                   	nop
80100ba0:	c9                   	leave
80100ba1:	c3                   	ret

80100ba2 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100ba2:	55                   	push   %ebp
80100ba3:	89 e5                	mov    %esp,%ebp
80100ba5:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100bab:	e8 a6 29 00 00       	call   80103556 <begin_op>
  if((ip = namei(path)) == 0){
80100bb0:	83 ec 0c             	sub    $0xc,%esp
80100bb3:	ff 75 08             	push   0x8(%ebp)
80100bb6:	e8 7f 19 00 00       	call   8010253a <namei>
80100bbb:	83 c4 10             	add    $0x10,%esp
80100bbe:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bc1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bc5:	75 0f                	jne    80100bd6 <exec+0x34>
    end_op();
80100bc7:	e8 16 2a 00 00       	call   801035e2 <end_op>
    return -1;
80100bcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bd1:	e9 ce 03 00 00       	jmp    80100fa4 <exec+0x402>
  }
  ilock(ip);
80100bd6:	83 ec 0c             	sub    $0xc,%esp
80100bd9:	ff 75 d8             	push   -0x28(%ebp)
80100bdc:	e8 a8 0d 00 00       	call   80101989 <ilock>
80100be1:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100be4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100beb:	6a 34                	push   $0x34
80100bed:	6a 00                	push   $0x0
80100bef:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100bf5:	50                   	push   %eax
80100bf6:	ff 75 d8             	push   -0x28(%ebp)
80100bf9:	e8 f4 12 00 00       	call   80101ef2 <readi>
80100bfe:	83 c4 10             	add    $0x10,%esp
80100c01:	83 f8 33             	cmp    $0x33,%eax
80100c04:	0f 86 49 03 00 00    	jbe    80100f53 <exec+0x3b1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c0a:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100c10:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c15:	0f 85 3b 03 00 00    	jne    80100f56 <exec+0x3b4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c1b:	e8 47 71 00 00       	call   80107d67 <setupkvm>
80100c20:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c23:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c27:	0f 84 2c 03 00 00    	je     80100f59 <exec+0x3b7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c2d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c34:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c3b:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100c41:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c44:	e9 ab 00 00 00       	jmp    80100cf4 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c49:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c4c:	6a 20                	push   $0x20
80100c4e:	50                   	push   %eax
80100c4f:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c55:	50                   	push   %eax
80100c56:	ff 75 d8             	push   -0x28(%ebp)
80100c59:	e8 94 12 00 00       	call   80101ef2 <readi>
80100c5e:	83 c4 10             	add    $0x10,%esp
80100c61:	83 f8 20             	cmp    $0x20,%eax
80100c64:	0f 85 f2 02 00 00    	jne    80100f5c <exec+0x3ba>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c6a:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c70:	83 f8 01             	cmp    $0x1,%eax
80100c73:	75 71                	jne    80100ce6 <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100c75:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c7b:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c81:	39 c2                	cmp    %eax,%edx
80100c83:	0f 82 d6 02 00 00    	jb     80100f5f <exec+0x3bd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c89:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c8f:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c95:	01 d0                	add    %edx,%eax
80100c97:	83 ec 04             	sub    $0x4,%esp
80100c9a:	50                   	push   %eax
80100c9b:	ff 75 e0             	push   -0x20(%ebp)
80100c9e:	ff 75 d4             	push   -0x2c(%ebp)
80100ca1:	e8 69 74 00 00       	call   8010810f <allocuvm>
80100ca6:	83 c4 10             	add    $0x10,%esp
80100ca9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cb0:	0f 84 ac 02 00 00    	je     80100f62 <exec+0x3c0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cb6:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100cbc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cc2:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100cc8:	83 ec 0c             	sub    $0xc,%esp
80100ccb:	52                   	push   %edx
80100ccc:	50                   	push   %eax
80100ccd:	ff 75 d8             	push   -0x28(%ebp)
80100cd0:	51                   	push   %ecx
80100cd1:	ff 75 d4             	push   -0x2c(%ebp)
80100cd4:	e8 5f 73 00 00       	call   80108038 <loaduvm>
80100cd9:	83 c4 20             	add    $0x20,%esp
80100cdc:	85 c0                	test   %eax,%eax
80100cde:	0f 88 81 02 00 00    	js     80100f65 <exec+0x3c3>
80100ce4:	eb 01                	jmp    80100ce7 <exec+0x145>
      continue;
80100ce6:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ce7:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100ceb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cee:	83 c0 20             	add    $0x20,%eax
80100cf1:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cf4:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100cfb:	0f b7 c0             	movzwl %ax,%eax
80100cfe:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d01:	0f 8c 42 ff ff ff    	jl     80100c49 <exec+0xa7>
      goto bad;
  }
  iunlockput(ip);
80100d07:	83 ec 0c             	sub    $0xc,%esp
80100d0a:	ff 75 d8             	push   -0x28(%ebp)
80100d0d:	e8 37 0f 00 00       	call   80101c49 <iunlockput>
80100d12:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d15:	e8 c8 28 00 00       	call   801035e2 <end_op>
  ip = 0;
80100d1a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d21:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d24:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d29:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d2e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d31:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d34:	05 00 20 00 00       	add    $0x2000,%eax
80100d39:	83 ec 04             	sub    $0x4,%esp
80100d3c:	50                   	push   %eax
80100d3d:	ff 75 e0             	push   -0x20(%ebp)
80100d40:	ff 75 d4             	push   -0x2c(%ebp)
80100d43:	e8 c7 73 00 00       	call   8010810f <allocuvm>
80100d48:	83 c4 10             	add    $0x10,%esp
80100d4b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d4e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d52:	0f 84 10 02 00 00    	je     80100f68 <exec+0x3c6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d58:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5b:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d60:	83 ec 08             	sub    $0x8,%esp
80100d63:	50                   	push   %eax
80100d64:	ff 75 d4             	push   -0x2c(%ebp)
80100d67:	e8 c7 75 00 00       	call   80108333 <clearpteu>
80100d6c:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d72:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d75:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d7c:	e9 96 00 00 00       	jmp    80100e17 <exec+0x275>
    if(argc >= MAXARG)
80100d81:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d85:	0f 87 e0 01 00 00    	ja     80100f6b <exec+0x3c9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d8e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d95:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d98:	01 d0                	add    %edx,%eax
80100d9a:	8b 00                	mov    (%eax),%eax
80100d9c:	83 ec 0c             	sub    $0xc,%esp
80100d9f:	50                   	push   %eax
80100da0:	e8 6f 47 00 00       	call   80105514 <strlen>
80100da5:	83 c4 10             	add    $0x10,%esp
80100da8:	89 c2                	mov    %eax,%edx
80100daa:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dad:	29 d0                	sub    %edx,%eax
80100daf:	83 e8 01             	sub    $0x1,%eax
80100db2:	83 e0 fc             	and    $0xfffffffc,%eax
80100db5:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100db8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dbb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc5:	01 d0                	add    %edx,%eax
80100dc7:	8b 00                	mov    (%eax),%eax
80100dc9:	83 ec 0c             	sub    $0xc,%esp
80100dcc:	50                   	push   %eax
80100dcd:	e8 42 47 00 00       	call   80105514 <strlen>
80100dd2:	83 c4 10             	add    $0x10,%esp
80100dd5:	83 c0 01             	add    $0x1,%eax
80100dd8:	89 c1                	mov    %eax,%ecx
80100dda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ddd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100de4:	8b 45 0c             	mov    0xc(%ebp),%eax
80100de7:	01 d0                	add    %edx,%eax
80100de9:	8b 00                	mov    (%eax),%eax
80100deb:	51                   	push   %ecx
80100dec:	50                   	push   %eax
80100ded:	ff 75 dc             	push   -0x24(%ebp)
80100df0:	ff 75 d4             	push   -0x2c(%ebp)
80100df3:	e8 f1 76 00 00       	call   801084e9 <copyout>
80100df8:	83 c4 10             	add    $0x10,%esp
80100dfb:	85 c0                	test   %eax,%eax
80100dfd:	0f 88 6b 01 00 00    	js     80100f6e <exec+0x3cc>
      goto bad;
    ustack[3+argc] = sp;
80100e03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e06:	8d 50 03             	lea    0x3(%eax),%edx
80100e09:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e0c:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e13:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e1a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e21:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e24:	01 d0                	add    %edx,%eax
80100e26:	8b 00                	mov    (%eax),%eax
80100e28:	85 c0                	test   %eax,%eax
80100e2a:	0f 85 51 ff ff ff    	jne    80100d81 <exec+0x1df>
  }
  ustack[3+argc] = 0;
80100e30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e33:	83 c0 03             	add    $0x3,%eax
80100e36:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100e3d:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e41:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e48:	ff ff ff 
  ustack[1] = argc;
80100e4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4e:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e57:	83 c0 01             	add    $0x1,%eax
80100e5a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e61:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e64:	29 d0                	sub    %edx,%eax
80100e66:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6f:	83 c0 04             	add    $0x4,%eax
80100e72:	c1 e0 02             	shl    $0x2,%eax
80100e75:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e7b:	83 c0 04             	add    $0x4,%eax
80100e7e:	c1 e0 02             	shl    $0x2,%eax
80100e81:	50                   	push   %eax
80100e82:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e88:	50                   	push   %eax
80100e89:	ff 75 dc             	push   -0x24(%ebp)
80100e8c:	ff 75 d4             	push   -0x2c(%ebp)
80100e8f:	e8 55 76 00 00       	call   801084e9 <copyout>
80100e94:	83 c4 10             	add    $0x10,%esp
80100e97:	85 c0                	test   %eax,%eax
80100e99:	0f 88 d2 00 00 00    	js     80100f71 <exec+0x3cf>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80100ea2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ea8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100eab:	eb 17                	jmp    80100ec4 <exec+0x322>
    if(*s == '/')
80100ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eb0:	0f b6 00             	movzbl (%eax),%eax
80100eb3:	3c 2f                	cmp    $0x2f,%al
80100eb5:	75 09                	jne    80100ec0 <exec+0x31e>
      last = s+1;
80100eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eba:	83 c0 01             	add    $0x1,%eax
80100ebd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ec0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ec7:	0f b6 00             	movzbl (%eax),%eax
80100eca:	84 c0                	test   %al,%al
80100ecc:	75 df                	jne    80100ead <exec+0x30b>
  safestrcpy(proc->name, last, sizeof(proc->name));
80100ece:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed4:	83 c0 6c             	add    $0x6c,%eax
80100ed7:	83 ec 04             	sub    $0x4,%esp
80100eda:	6a 10                	push   $0x10
80100edc:	ff 75 f0             	push   -0x10(%ebp)
80100edf:	50                   	push   %eax
80100ee0:	e8 e4 45 00 00       	call   801054c9 <safestrcpy>
80100ee5:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100ee8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eee:	8b 40 04             	mov    0x4(%eax),%eax
80100ef1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ef4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100efa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100efd:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100f00:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f06:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f09:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100f0b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f11:	8b 40 18             	mov    0x18(%eax),%eax
80100f14:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100f1a:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100f1d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f23:	8b 40 18             	mov    0x18(%eax),%eax
80100f26:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f29:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100f2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f32:	83 ec 0c             	sub    $0xc,%esp
80100f35:	50                   	push   %eax
80100f36:	e8 13 6f 00 00       	call   80107e4e <switchuvm>
80100f3b:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f3e:	83 ec 0c             	sub    $0xc,%esp
80100f41:	ff 75 d0             	push   -0x30(%ebp)
80100f44:	e8 4a 73 00 00       	call   80108293 <freevm>
80100f49:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f4c:	b8 00 00 00 00       	mov    $0x0,%eax
80100f51:	eb 51                	jmp    80100fa4 <exec+0x402>
    goto bad;
80100f53:	90                   	nop
80100f54:	eb 1c                	jmp    80100f72 <exec+0x3d0>
    goto bad;
80100f56:	90                   	nop
80100f57:	eb 19                	jmp    80100f72 <exec+0x3d0>
    goto bad;
80100f59:	90                   	nop
80100f5a:	eb 16                	jmp    80100f72 <exec+0x3d0>
      goto bad;
80100f5c:	90                   	nop
80100f5d:	eb 13                	jmp    80100f72 <exec+0x3d0>
      goto bad;
80100f5f:	90                   	nop
80100f60:	eb 10                	jmp    80100f72 <exec+0x3d0>
      goto bad;
80100f62:	90                   	nop
80100f63:	eb 0d                	jmp    80100f72 <exec+0x3d0>
      goto bad;
80100f65:	90                   	nop
80100f66:	eb 0a                	jmp    80100f72 <exec+0x3d0>
    goto bad;
80100f68:	90                   	nop
80100f69:	eb 07                	jmp    80100f72 <exec+0x3d0>
      goto bad;
80100f6b:	90                   	nop
80100f6c:	eb 04                	jmp    80100f72 <exec+0x3d0>
      goto bad;
80100f6e:	90                   	nop
80100f6f:	eb 01                	jmp    80100f72 <exec+0x3d0>
    goto bad;
80100f71:	90                   	nop

 bad:
  if(pgdir)
80100f72:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f76:	74 0e                	je     80100f86 <exec+0x3e4>
    freevm(pgdir);
80100f78:	83 ec 0c             	sub    $0xc,%esp
80100f7b:	ff 75 d4             	push   -0x2c(%ebp)
80100f7e:	e8 10 73 00 00       	call   80108293 <freevm>
80100f83:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f86:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f8a:	74 13                	je     80100f9f <exec+0x3fd>
    iunlockput(ip);
80100f8c:	83 ec 0c             	sub    $0xc,%esp
80100f8f:	ff 75 d8             	push   -0x28(%ebp)
80100f92:	e8 b2 0c 00 00       	call   80101c49 <iunlockput>
80100f97:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f9a:	e8 43 26 00 00       	call   801035e2 <end_op>
  }
  return -1;
80100f9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fa4:	c9                   	leave
80100fa5:	c3                   	ret

80100fa6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fa6:	55                   	push   %ebp
80100fa7:	89 e5                	mov    %esp,%ebp
80100fa9:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fac:	83 ec 08             	sub    $0x8,%esp
80100faf:	68 ee 85 10 80       	push   $0x801085ee
80100fb4:	68 00 f8 10 80       	push   $0x8010f800
80100fb9:	e8 82 40 00 00       	call   80105040 <initlock>
80100fbe:	83 c4 10             	add    $0x10,%esp
}
80100fc1:	90                   	nop
80100fc2:	c9                   	leave
80100fc3:	c3                   	ret

80100fc4 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fc4:	55                   	push   %ebp
80100fc5:	89 e5                	mov    %esp,%ebp
80100fc7:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fca:	83 ec 0c             	sub    $0xc,%esp
80100fcd:	68 00 f8 10 80       	push   $0x8010f800
80100fd2:	e8 8b 40 00 00       	call   80105062 <acquire>
80100fd7:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fda:	c7 45 f4 34 f8 10 80 	movl   $0x8010f834,-0xc(%ebp)
80100fe1:	eb 2d                	jmp    80101010 <filealloc+0x4c>
    if(f->ref == 0){
80100fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fe6:	8b 40 04             	mov    0x4(%eax),%eax
80100fe9:	85 c0                	test   %eax,%eax
80100feb:	75 1f                	jne    8010100c <filealloc+0x48>
      f->ref = 1;
80100fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ff0:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100ff7:	83 ec 0c             	sub    $0xc,%esp
80100ffa:	68 00 f8 10 80       	push   $0x8010f800
80100fff:	e8 c5 40 00 00       	call   801050c9 <release>
80101004:	83 c4 10             	add    $0x10,%esp
      return f;
80101007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010100a:	eb 23                	jmp    8010102f <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010100c:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101010:	b8 94 01 11 80       	mov    $0x80110194,%eax
80101015:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101018:	72 c9                	jb     80100fe3 <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
8010101a:	83 ec 0c             	sub    $0xc,%esp
8010101d:	68 00 f8 10 80       	push   $0x8010f800
80101022:	e8 a2 40 00 00       	call   801050c9 <release>
80101027:	83 c4 10             	add    $0x10,%esp
  return 0;
8010102a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010102f:	c9                   	leave
80101030:	c3                   	ret

80101031 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101031:	55                   	push   %ebp
80101032:	89 e5                	mov    %esp,%ebp
80101034:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101037:	83 ec 0c             	sub    $0xc,%esp
8010103a:	68 00 f8 10 80       	push   $0x8010f800
8010103f:	e8 1e 40 00 00       	call   80105062 <acquire>
80101044:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101047:	8b 45 08             	mov    0x8(%ebp),%eax
8010104a:	8b 40 04             	mov    0x4(%eax),%eax
8010104d:	85 c0                	test   %eax,%eax
8010104f:	7f 0d                	jg     8010105e <filedup+0x2d>
    panic("filedup");
80101051:	83 ec 0c             	sub    $0xc,%esp
80101054:	68 f5 85 10 80       	push   $0x801085f5
80101059:	e8 1b f5 ff ff       	call   80100579 <panic>
  f->ref++;
8010105e:	8b 45 08             	mov    0x8(%ebp),%eax
80101061:	8b 40 04             	mov    0x4(%eax),%eax
80101064:	8d 50 01             	lea    0x1(%eax),%edx
80101067:	8b 45 08             	mov    0x8(%ebp),%eax
8010106a:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010106d:	83 ec 0c             	sub    $0xc,%esp
80101070:	68 00 f8 10 80       	push   $0x8010f800
80101075:	e8 4f 40 00 00       	call   801050c9 <release>
8010107a:	83 c4 10             	add    $0x10,%esp
  return f;
8010107d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101080:	c9                   	leave
80101081:	c3                   	ret

80101082 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101082:	55                   	push   %ebp
80101083:	89 e5                	mov    %esp,%ebp
80101085:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101088:	83 ec 0c             	sub    $0xc,%esp
8010108b:	68 00 f8 10 80       	push   $0x8010f800
80101090:	e8 cd 3f 00 00       	call   80105062 <acquire>
80101095:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101098:	8b 45 08             	mov    0x8(%ebp),%eax
8010109b:	8b 40 04             	mov    0x4(%eax),%eax
8010109e:	85 c0                	test   %eax,%eax
801010a0:	7f 0d                	jg     801010af <fileclose+0x2d>
    panic("fileclose");
801010a2:	83 ec 0c             	sub    $0xc,%esp
801010a5:	68 fd 85 10 80       	push   $0x801085fd
801010aa:	e8 ca f4 ff ff       	call   80100579 <panic>
  if(--f->ref > 0){
801010af:	8b 45 08             	mov    0x8(%ebp),%eax
801010b2:	8b 40 04             	mov    0x4(%eax),%eax
801010b5:	8d 50 ff             	lea    -0x1(%eax),%edx
801010b8:	8b 45 08             	mov    0x8(%ebp),%eax
801010bb:	89 50 04             	mov    %edx,0x4(%eax)
801010be:	8b 45 08             	mov    0x8(%ebp),%eax
801010c1:	8b 40 04             	mov    0x4(%eax),%eax
801010c4:	85 c0                	test   %eax,%eax
801010c6:	7e 15                	jle    801010dd <fileclose+0x5b>
    release(&ftable.lock);
801010c8:	83 ec 0c             	sub    $0xc,%esp
801010cb:	68 00 f8 10 80       	push   $0x8010f800
801010d0:	e8 f4 3f 00 00       	call   801050c9 <release>
801010d5:	83 c4 10             	add    $0x10,%esp
801010d8:	e9 8b 00 00 00       	jmp    80101168 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010dd:	8b 45 08             	mov    0x8(%ebp),%eax
801010e0:	8b 10                	mov    (%eax),%edx
801010e2:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010e5:	8b 50 04             	mov    0x4(%eax),%edx
801010e8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010eb:	8b 50 08             	mov    0x8(%eax),%edx
801010ee:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010f1:	8b 50 0c             	mov    0xc(%eax),%edx
801010f4:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010f7:	8b 50 10             	mov    0x10(%eax),%edx
801010fa:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010fd:	8b 40 14             	mov    0x14(%eax),%eax
80101100:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101103:	8b 45 08             	mov    0x8(%ebp),%eax
80101106:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010110d:	8b 45 08             	mov    0x8(%ebp),%eax
80101110:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101116:	83 ec 0c             	sub    $0xc,%esp
80101119:	68 00 f8 10 80       	push   $0x8010f800
8010111e:	e8 a6 3f 00 00       	call   801050c9 <release>
80101123:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
80101126:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101129:	83 f8 01             	cmp    $0x1,%eax
8010112c:	75 19                	jne    80101147 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
8010112e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101132:	0f be d0             	movsbl %al,%edx
80101135:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101138:	83 ec 08             	sub    $0x8,%esp
8010113b:	52                   	push   %edx
8010113c:	50                   	push   %eax
8010113d:	e8 91 30 00 00       	call   801041d3 <pipeclose>
80101142:	83 c4 10             	add    $0x10,%esp
80101145:	eb 21                	jmp    80101168 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101147:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010114a:	83 f8 02             	cmp    $0x2,%eax
8010114d:	75 19                	jne    80101168 <fileclose+0xe6>
    begin_op();
8010114f:	e8 02 24 00 00       	call   80103556 <begin_op>
    iput(ff.ip);
80101154:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101157:	83 ec 0c             	sub    $0xc,%esp
8010115a:	50                   	push   %eax
8010115b:	e8 f9 09 00 00       	call   80101b59 <iput>
80101160:	83 c4 10             	add    $0x10,%esp
    end_op();
80101163:	e8 7a 24 00 00       	call   801035e2 <end_op>
  }
}
80101168:	c9                   	leave
80101169:	c3                   	ret

8010116a <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010116a:	55                   	push   %ebp
8010116b:	89 e5                	mov    %esp,%ebp
8010116d:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101170:	8b 45 08             	mov    0x8(%ebp),%eax
80101173:	8b 00                	mov    (%eax),%eax
80101175:	83 f8 02             	cmp    $0x2,%eax
80101178:	75 40                	jne    801011ba <filestat+0x50>
    ilock(f->ip);
8010117a:	8b 45 08             	mov    0x8(%ebp),%eax
8010117d:	8b 40 10             	mov    0x10(%eax),%eax
80101180:	83 ec 0c             	sub    $0xc,%esp
80101183:	50                   	push   %eax
80101184:	e8 00 08 00 00       	call   80101989 <ilock>
80101189:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010118c:	8b 45 08             	mov    0x8(%ebp),%eax
8010118f:	8b 40 10             	mov    0x10(%eax),%eax
80101192:	83 ec 08             	sub    $0x8,%esp
80101195:	ff 75 0c             	push   0xc(%ebp)
80101198:	50                   	push   %eax
80101199:	e8 0e 0d 00 00       	call   80101eac <stati>
8010119e:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011a1:	8b 45 08             	mov    0x8(%ebp),%eax
801011a4:	8b 40 10             	mov    0x10(%eax),%eax
801011a7:	83 ec 0c             	sub    $0xc,%esp
801011aa:	50                   	push   %eax
801011ab:	e8 37 09 00 00       	call   80101ae7 <iunlock>
801011b0:	83 c4 10             	add    $0x10,%esp
    return 0;
801011b3:	b8 00 00 00 00       	mov    $0x0,%eax
801011b8:	eb 05                	jmp    801011bf <filestat+0x55>
  }
  return -1;
801011ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011bf:	c9                   	leave
801011c0:	c3                   	ret

801011c1 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011c1:	55                   	push   %ebp
801011c2:	89 e5                	mov    %esp,%ebp
801011c4:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011c7:	8b 45 08             	mov    0x8(%ebp),%eax
801011ca:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011ce:	84 c0                	test   %al,%al
801011d0:	75 0a                	jne    801011dc <fileread+0x1b>
    return -1;
801011d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011d7:	e9 9b 00 00 00       	jmp    80101277 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011dc:	8b 45 08             	mov    0x8(%ebp),%eax
801011df:	8b 00                	mov    (%eax),%eax
801011e1:	83 f8 01             	cmp    $0x1,%eax
801011e4:	75 1a                	jne    80101200 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011e6:	8b 45 08             	mov    0x8(%ebp),%eax
801011e9:	8b 40 0c             	mov    0xc(%eax),%eax
801011ec:	83 ec 04             	sub    $0x4,%esp
801011ef:	ff 75 10             	push   0x10(%ebp)
801011f2:	ff 75 0c             	push   0xc(%ebp)
801011f5:	50                   	push   %eax
801011f6:	e8 86 31 00 00       	call   80104381 <piperead>
801011fb:	83 c4 10             	add    $0x10,%esp
801011fe:	eb 77                	jmp    80101277 <fileread+0xb6>
  if(f->type == FD_INODE){
80101200:	8b 45 08             	mov    0x8(%ebp),%eax
80101203:	8b 00                	mov    (%eax),%eax
80101205:	83 f8 02             	cmp    $0x2,%eax
80101208:	75 60                	jne    8010126a <fileread+0xa9>
    ilock(f->ip);
8010120a:	8b 45 08             	mov    0x8(%ebp),%eax
8010120d:	8b 40 10             	mov    0x10(%eax),%eax
80101210:	83 ec 0c             	sub    $0xc,%esp
80101213:	50                   	push   %eax
80101214:	e8 70 07 00 00       	call   80101989 <ilock>
80101219:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010121c:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010121f:	8b 45 08             	mov    0x8(%ebp),%eax
80101222:	8b 50 14             	mov    0x14(%eax),%edx
80101225:	8b 45 08             	mov    0x8(%ebp),%eax
80101228:	8b 40 10             	mov    0x10(%eax),%eax
8010122b:	51                   	push   %ecx
8010122c:	52                   	push   %edx
8010122d:	ff 75 0c             	push   0xc(%ebp)
80101230:	50                   	push   %eax
80101231:	e8 bc 0c 00 00       	call   80101ef2 <readi>
80101236:	83 c4 10             	add    $0x10,%esp
80101239:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010123c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101240:	7e 11                	jle    80101253 <fileread+0x92>
      f->off += r;
80101242:	8b 45 08             	mov    0x8(%ebp),%eax
80101245:	8b 50 14             	mov    0x14(%eax),%edx
80101248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010124b:	01 c2                	add    %eax,%edx
8010124d:	8b 45 08             	mov    0x8(%ebp),%eax
80101250:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101253:	8b 45 08             	mov    0x8(%ebp),%eax
80101256:	8b 40 10             	mov    0x10(%eax),%eax
80101259:	83 ec 0c             	sub    $0xc,%esp
8010125c:	50                   	push   %eax
8010125d:	e8 85 08 00 00       	call   80101ae7 <iunlock>
80101262:	83 c4 10             	add    $0x10,%esp
    return r;
80101265:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101268:	eb 0d                	jmp    80101277 <fileread+0xb6>
  }
  panic("fileread");
8010126a:	83 ec 0c             	sub    $0xc,%esp
8010126d:	68 07 86 10 80       	push   $0x80108607
80101272:	e8 02 f3 ff ff       	call   80100579 <panic>
}
80101277:	c9                   	leave
80101278:	c3                   	ret

80101279 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101279:	55                   	push   %ebp
8010127a:	89 e5                	mov    %esp,%ebp
8010127c:	53                   	push   %ebx
8010127d:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101280:	8b 45 08             	mov    0x8(%ebp),%eax
80101283:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101287:	84 c0                	test   %al,%al
80101289:	75 0a                	jne    80101295 <filewrite+0x1c>
    return -1;
8010128b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101290:	e9 1b 01 00 00       	jmp    801013b0 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101295:	8b 45 08             	mov    0x8(%ebp),%eax
80101298:	8b 00                	mov    (%eax),%eax
8010129a:	83 f8 01             	cmp    $0x1,%eax
8010129d:	75 1d                	jne    801012bc <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
8010129f:	8b 45 08             	mov    0x8(%ebp),%eax
801012a2:	8b 40 0c             	mov    0xc(%eax),%eax
801012a5:	83 ec 04             	sub    $0x4,%esp
801012a8:	ff 75 10             	push   0x10(%ebp)
801012ab:	ff 75 0c             	push   0xc(%ebp)
801012ae:	50                   	push   %eax
801012af:	e8 ca 2f 00 00       	call   8010427e <pipewrite>
801012b4:	83 c4 10             	add    $0x10,%esp
801012b7:	e9 f4 00 00 00       	jmp    801013b0 <filewrite+0x137>
  if(f->type == FD_INODE){
801012bc:	8b 45 08             	mov    0x8(%ebp),%eax
801012bf:	8b 00                	mov    (%eax),%eax
801012c1:	83 f8 02             	cmp    $0x2,%eax
801012c4:	0f 85 d9 00 00 00    	jne    801013a3 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801012ca:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801012d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012d8:	e9 a3 00 00 00       	jmp    80101380 <filewrite+0x107>
      int n1 = n - i;
801012dd:	8b 45 10             	mov    0x10(%ebp),%eax
801012e0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012e9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012ec:	7e 06                	jle    801012f4 <filewrite+0x7b>
        n1 = max;
801012ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012f1:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012f4:	e8 5d 22 00 00       	call   80103556 <begin_op>
      ilock(f->ip);
801012f9:	8b 45 08             	mov    0x8(%ebp),%eax
801012fc:	8b 40 10             	mov    0x10(%eax),%eax
801012ff:	83 ec 0c             	sub    $0xc,%esp
80101302:	50                   	push   %eax
80101303:	e8 81 06 00 00       	call   80101989 <ilock>
80101308:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010130b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010130e:	8b 45 08             	mov    0x8(%ebp),%eax
80101311:	8b 50 14             	mov    0x14(%eax),%edx
80101314:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101317:	8b 45 0c             	mov    0xc(%ebp),%eax
8010131a:	01 c3                	add    %eax,%ebx
8010131c:	8b 45 08             	mov    0x8(%ebp),%eax
8010131f:	8b 40 10             	mov    0x10(%eax),%eax
80101322:	51                   	push   %ecx
80101323:	52                   	push   %edx
80101324:	53                   	push   %ebx
80101325:	50                   	push   %eax
80101326:	e8 1c 0d 00 00       	call   80102047 <writei>
8010132b:	83 c4 10             	add    $0x10,%esp
8010132e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101331:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101335:	7e 11                	jle    80101348 <filewrite+0xcf>
        f->off += r;
80101337:	8b 45 08             	mov    0x8(%ebp),%eax
8010133a:	8b 50 14             	mov    0x14(%eax),%edx
8010133d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101340:	01 c2                	add    %eax,%edx
80101342:	8b 45 08             	mov    0x8(%ebp),%eax
80101345:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101348:	8b 45 08             	mov    0x8(%ebp),%eax
8010134b:	8b 40 10             	mov    0x10(%eax),%eax
8010134e:	83 ec 0c             	sub    $0xc,%esp
80101351:	50                   	push   %eax
80101352:	e8 90 07 00 00       	call   80101ae7 <iunlock>
80101357:	83 c4 10             	add    $0x10,%esp
      end_op();
8010135a:	e8 83 22 00 00       	call   801035e2 <end_op>

      if(r < 0)
8010135f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101363:	78 29                	js     8010138e <filewrite+0x115>
        break;
      if(r != n1)
80101365:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101368:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010136b:	74 0d                	je     8010137a <filewrite+0x101>
        panic("short filewrite");
8010136d:	83 ec 0c             	sub    $0xc,%esp
80101370:	68 10 86 10 80       	push   $0x80108610
80101375:	e8 ff f1 ff ff       	call   80100579 <panic>
      i += r;
8010137a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010137d:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101383:	3b 45 10             	cmp    0x10(%ebp),%eax
80101386:	0f 8c 51 ff ff ff    	jl     801012dd <filewrite+0x64>
8010138c:	eb 01                	jmp    8010138f <filewrite+0x116>
        break;
8010138e:	90                   	nop
    }
    return i == n ? n : -1;
8010138f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101392:	3b 45 10             	cmp    0x10(%ebp),%eax
80101395:	75 05                	jne    8010139c <filewrite+0x123>
80101397:	8b 45 10             	mov    0x10(%ebp),%eax
8010139a:	eb 14                	jmp    801013b0 <filewrite+0x137>
8010139c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013a1:	eb 0d                	jmp    801013b0 <filewrite+0x137>
  }
  panic("filewrite");
801013a3:	83 ec 0c             	sub    $0xc,%esp
801013a6:	68 20 86 10 80       	push   $0x80108620
801013ab:	e8 c9 f1 ff ff       	call   80100579 <panic>
}
801013b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013b3:	c9                   	leave
801013b4:	c3                   	ret

801013b5 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013b5:	55                   	push   %ebp
801013b6:	89 e5                	mov    %esp,%ebp
801013b8:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801013bb:	8b 45 08             	mov    0x8(%ebp),%eax
801013be:	83 ec 08             	sub    $0x8,%esp
801013c1:	6a 01                	push   $0x1
801013c3:	50                   	push   %eax
801013c4:	e8 ee ed ff ff       	call   801001b7 <bread>
801013c9:	83 c4 10             	add    $0x10,%esp
801013cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013d2:	83 c0 18             	add    $0x18,%eax
801013d5:	83 ec 04             	sub    $0x4,%esp
801013d8:	6a 1c                	push   $0x1c
801013da:	50                   	push   %eax
801013db:	ff 75 0c             	push   0xc(%ebp)
801013de:	e8 a2 3f 00 00       	call   80105385 <memmove>
801013e3:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013e6:	83 ec 0c             	sub    $0xc,%esp
801013e9:	ff 75 f4             	push   -0xc(%ebp)
801013ec:	e8 3e ee ff ff       	call   8010022f <brelse>
801013f1:	83 c4 10             	add    $0x10,%esp
}
801013f4:	90                   	nop
801013f5:	c9                   	leave
801013f6:	c3                   	ret

801013f7 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013f7:	55                   	push   %ebp
801013f8:	89 e5                	mov    %esp,%ebp
801013fa:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013fd:	8b 55 0c             	mov    0xc(%ebp),%edx
80101400:	8b 45 08             	mov    0x8(%ebp),%eax
80101403:	83 ec 08             	sub    $0x8,%esp
80101406:	52                   	push   %edx
80101407:	50                   	push   %eax
80101408:	e8 aa ed ff ff       	call   801001b7 <bread>
8010140d:	83 c4 10             	add    $0x10,%esp
80101410:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101416:	83 c0 18             	add    $0x18,%eax
80101419:	83 ec 04             	sub    $0x4,%esp
8010141c:	68 00 02 00 00       	push   $0x200
80101421:	6a 00                	push   $0x0
80101423:	50                   	push   %eax
80101424:	e8 9d 3e 00 00       	call   801052c6 <memset>
80101429:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010142c:	83 ec 0c             	sub    $0xc,%esp
8010142f:	ff 75 f4             	push   -0xc(%ebp)
80101432:	e8 58 23 00 00       	call   8010378f <log_write>
80101437:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010143a:	83 ec 0c             	sub    $0xc,%esp
8010143d:	ff 75 f4             	push   -0xc(%ebp)
80101440:	e8 ea ed ff ff       	call   8010022f <brelse>
80101445:	83 c4 10             	add    $0x10,%esp
}
80101448:	90                   	nop
80101449:	c9                   	leave
8010144a:	c3                   	ret

8010144b <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010144b:	55                   	push   %ebp
8010144c:	89 e5                	mov    %esp,%ebp
8010144e:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101451:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101458:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010145f:	e9 0b 01 00 00       	jmp    8010156f <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
80101464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101467:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010146d:	85 c0                	test   %eax,%eax
8010146f:	0f 48 c2             	cmovs  %edx,%eax
80101472:	c1 f8 0c             	sar    $0xc,%eax
80101475:	89 c2                	mov    %eax,%edx
80101477:	a1 b8 01 11 80       	mov    0x801101b8,%eax
8010147c:	01 d0                	add    %edx,%eax
8010147e:	83 ec 08             	sub    $0x8,%esp
80101481:	50                   	push   %eax
80101482:	ff 75 08             	push   0x8(%ebp)
80101485:	e8 2d ed ff ff       	call   801001b7 <bread>
8010148a:	83 c4 10             	add    $0x10,%esp
8010148d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101490:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101497:	e9 9e 00 00 00       	jmp    8010153a <balloc+0xef>
      m = 1 << (bi % 8);
8010149c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010149f:	83 e0 07             	and    $0x7,%eax
801014a2:	ba 01 00 00 00       	mov    $0x1,%edx
801014a7:	89 c1                	mov    %eax,%ecx
801014a9:	d3 e2                	shl    %cl,%edx
801014ab:	89 d0                	mov    %edx,%eax
801014ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b3:	8d 50 07             	lea    0x7(%eax),%edx
801014b6:	85 c0                	test   %eax,%eax
801014b8:	0f 48 c2             	cmovs  %edx,%eax
801014bb:	c1 f8 03             	sar    $0x3,%eax
801014be:	89 c2                	mov    %eax,%edx
801014c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014c3:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801014c8:	0f b6 c0             	movzbl %al,%eax
801014cb:	23 45 e8             	and    -0x18(%ebp),%eax
801014ce:	85 c0                	test   %eax,%eax
801014d0:	75 64                	jne    80101536 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d5:	8d 50 07             	lea    0x7(%eax),%edx
801014d8:	85 c0                	test   %eax,%eax
801014da:	0f 48 c2             	cmovs  %edx,%eax
801014dd:	c1 f8 03             	sar    $0x3,%eax
801014e0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014e3:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014e8:	89 d1                	mov    %edx,%ecx
801014ea:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014ed:	09 ca                	or     %ecx,%edx
801014ef:	89 d1                	mov    %edx,%ecx
801014f1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014f4:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014f8:	83 ec 0c             	sub    $0xc,%esp
801014fb:	ff 75 ec             	push   -0x14(%ebp)
801014fe:	e8 8c 22 00 00       	call   8010378f <log_write>
80101503:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101506:	83 ec 0c             	sub    $0xc,%esp
80101509:	ff 75 ec             	push   -0x14(%ebp)
8010150c:	e8 1e ed ff ff       	call   8010022f <brelse>
80101511:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101514:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101517:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010151a:	01 c2                	add    %eax,%edx
8010151c:	8b 45 08             	mov    0x8(%ebp),%eax
8010151f:	83 ec 08             	sub    $0x8,%esp
80101522:	52                   	push   %edx
80101523:	50                   	push   %eax
80101524:	e8 ce fe ff ff       	call   801013f7 <bzero>
80101529:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010152c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010152f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101532:	01 d0                	add    %edx,%eax
80101534:	eb 56                	jmp    8010158c <balloc+0x141>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101536:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010153a:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101541:	7f 17                	jg     8010155a <balloc+0x10f>
80101543:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101546:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101549:	01 d0                	add    %edx,%eax
8010154b:	89 c2                	mov    %eax,%edx
8010154d:	a1 a0 01 11 80       	mov    0x801101a0,%eax
80101552:	39 c2                	cmp    %eax,%edx
80101554:	0f 82 42 ff ff ff    	jb     8010149c <balloc+0x51>
      }
    }
    brelse(bp);
8010155a:	83 ec 0c             	sub    $0xc,%esp
8010155d:	ff 75 ec             	push   -0x14(%ebp)
80101560:	e8 ca ec ff ff       	call   8010022f <brelse>
80101565:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101568:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010156f:	a1 a0 01 11 80       	mov    0x801101a0,%eax
80101574:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101577:	39 c2                	cmp    %eax,%edx
80101579:	0f 82 e5 fe ff ff    	jb     80101464 <balloc+0x19>
  }
  panic("balloc: out of blocks");
8010157f:	83 ec 0c             	sub    $0xc,%esp
80101582:	68 2c 86 10 80       	push   $0x8010862c
80101587:	e8 ed ef ff ff       	call   80100579 <panic>
}
8010158c:	c9                   	leave
8010158d:	c3                   	ret

8010158e <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010158e:	55                   	push   %ebp
8010158f:	89 e5                	mov    %esp,%ebp
80101591:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101594:	83 ec 08             	sub    $0x8,%esp
80101597:	68 a0 01 11 80       	push   $0x801101a0
8010159c:	ff 75 08             	push   0x8(%ebp)
8010159f:	e8 11 fe ff ff       	call   801013b5 <readsb>
801015a4:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801015aa:	c1 e8 0c             	shr    $0xc,%eax
801015ad:	89 c2                	mov    %eax,%edx
801015af:	a1 b8 01 11 80       	mov    0x801101b8,%eax
801015b4:	01 c2                	add    %eax,%edx
801015b6:	8b 45 08             	mov    0x8(%ebp),%eax
801015b9:	83 ec 08             	sub    $0x8,%esp
801015bc:	52                   	push   %edx
801015bd:	50                   	push   %eax
801015be:	e8 f4 eb ff ff       	call   801001b7 <bread>
801015c3:	83 c4 10             	add    $0x10,%esp
801015c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801015cc:	25 ff 0f 00 00       	and    $0xfff,%eax
801015d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d7:	83 e0 07             	and    $0x7,%eax
801015da:	ba 01 00 00 00       	mov    $0x1,%edx
801015df:	89 c1                	mov    %eax,%ecx
801015e1:	d3 e2                	shl    %cl,%edx
801015e3:	89 d0                	mov    %edx,%eax
801015e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015eb:	8d 50 07             	lea    0x7(%eax),%edx
801015ee:	85 c0                	test   %eax,%eax
801015f0:	0f 48 c2             	cmovs  %edx,%eax
801015f3:	c1 f8 03             	sar    $0x3,%eax
801015f6:	89 c2                	mov    %eax,%edx
801015f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015fb:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101600:	0f b6 c0             	movzbl %al,%eax
80101603:	23 45 ec             	and    -0x14(%ebp),%eax
80101606:	85 c0                	test   %eax,%eax
80101608:	75 0d                	jne    80101617 <bfree+0x89>
    panic("freeing free block");
8010160a:	83 ec 0c             	sub    $0xc,%esp
8010160d:	68 42 86 10 80       	push   $0x80108642
80101612:	e8 62 ef ff ff       	call   80100579 <panic>
  bp->data[bi/8] &= ~m;
80101617:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010161a:	8d 50 07             	lea    0x7(%eax),%edx
8010161d:	85 c0                	test   %eax,%eax
8010161f:	0f 48 c2             	cmovs  %edx,%eax
80101622:	c1 f8 03             	sar    $0x3,%eax
80101625:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101628:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010162d:	89 d1                	mov    %edx,%ecx
8010162f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101632:	f7 d2                	not    %edx
80101634:	21 ca                	and    %ecx,%edx
80101636:	89 d1                	mov    %edx,%ecx
80101638:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010163b:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
8010163f:	83 ec 0c             	sub    $0xc,%esp
80101642:	ff 75 f4             	push   -0xc(%ebp)
80101645:	e8 45 21 00 00       	call   8010378f <log_write>
8010164a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010164d:	83 ec 0c             	sub    $0xc,%esp
80101650:	ff 75 f4             	push   -0xc(%ebp)
80101653:	e8 d7 eb ff ff       	call   8010022f <brelse>
80101658:	83 c4 10             	add    $0x10,%esp
}
8010165b:	90                   	nop
8010165c:	c9                   	leave
8010165d:	c3                   	ret

8010165e <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010165e:	55                   	push   %ebp
8010165f:	89 e5                	mov    %esp,%ebp
80101661:	57                   	push   %edi
80101662:	56                   	push   %esi
80101663:	53                   	push   %ebx
80101664:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
80101667:	83 ec 08             	sub    $0x8,%esp
8010166a:	68 55 86 10 80       	push   $0x80108655
8010166f:	68 c0 01 11 80       	push   $0x801101c0
80101674:	e8 c7 39 00 00       	call   80105040 <initlock>
80101679:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010167c:	83 ec 08             	sub    $0x8,%esp
8010167f:	68 a0 01 11 80       	push   $0x801101a0
80101684:	ff 75 08             	push   0x8(%ebp)
80101687:	e8 29 fd ff ff       	call   801013b5 <readsb>
8010168c:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
8010168f:	a1 b8 01 11 80       	mov    0x801101b8,%eax
80101694:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101697:	8b 3d b4 01 11 80    	mov    0x801101b4,%edi
8010169d:	8b 35 b0 01 11 80    	mov    0x801101b0,%esi
801016a3:	8b 1d ac 01 11 80    	mov    0x801101ac,%ebx
801016a9:	8b 0d a8 01 11 80    	mov    0x801101a8,%ecx
801016af:	8b 15 a4 01 11 80    	mov    0x801101a4,%edx
801016b5:	a1 a0 01 11 80       	mov    0x801101a0,%eax
801016ba:	ff 75 e4             	push   -0x1c(%ebp)
801016bd:	57                   	push   %edi
801016be:	56                   	push   %esi
801016bf:	53                   	push   %ebx
801016c0:	51                   	push   %ecx
801016c1:	52                   	push   %edx
801016c2:	50                   	push   %eax
801016c3:	68 5c 86 10 80       	push   $0x8010865c
801016c8:	e8 f7 ec ff ff       	call   801003c4 <cprintf>
801016cd:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
801016d0:	90                   	nop
801016d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016d4:	5b                   	pop    %ebx
801016d5:	5e                   	pop    %esi
801016d6:	5f                   	pop    %edi
801016d7:	5d                   	pop    %ebp
801016d8:	c3                   	ret

801016d9 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801016d9:	55                   	push   %ebp
801016da:	89 e5                	mov    %esp,%ebp
801016dc:	83 ec 28             	sub    $0x28,%esp
801016df:	8b 45 0c             	mov    0xc(%ebp),%eax
801016e2:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016e6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016ed:	e9 9e 00 00 00       	jmp    80101790 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801016f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016f5:	c1 e8 03             	shr    $0x3,%eax
801016f8:	89 c2                	mov    %eax,%edx
801016fa:	a1 b4 01 11 80       	mov    0x801101b4,%eax
801016ff:	01 d0                	add    %edx,%eax
80101701:	83 ec 08             	sub    $0x8,%esp
80101704:	50                   	push   %eax
80101705:	ff 75 08             	push   0x8(%ebp)
80101708:	e8 aa ea ff ff       	call   801001b7 <bread>
8010170d:	83 c4 10             	add    $0x10,%esp
80101710:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101713:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101716:	8d 50 18             	lea    0x18(%eax),%edx
80101719:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010171c:	83 e0 07             	and    $0x7,%eax
8010171f:	c1 e0 06             	shl    $0x6,%eax
80101722:	01 d0                	add    %edx,%eax
80101724:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101727:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010172a:	0f b7 00             	movzwl (%eax),%eax
8010172d:	66 85 c0             	test   %ax,%ax
80101730:	75 4c                	jne    8010177e <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101732:	83 ec 04             	sub    $0x4,%esp
80101735:	6a 40                	push   $0x40
80101737:	6a 00                	push   $0x0
80101739:	ff 75 ec             	push   -0x14(%ebp)
8010173c:	e8 85 3b 00 00       	call   801052c6 <memset>
80101741:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101744:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101747:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010174b:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010174e:	83 ec 0c             	sub    $0xc,%esp
80101751:	ff 75 f0             	push   -0x10(%ebp)
80101754:	e8 36 20 00 00       	call   8010378f <log_write>
80101759:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010175c:	83 ec 0c             	sub    $0xc,%esp
8010175f:	ff 75 f0             	push   -0x10(%ebp)
80101762:	e8 c8 ea ff ff       	call   8010022f <brelse>
80101767:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010176a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010176d:	83 ec 08             	sub    $0x8,%esp
80101770:	50                   	push   %eax
80101771:	ff 75 08             	push   0x8(%ebp)
80101774:	e8 f7 00 00 00       	call   80101870 <iget>
80101779:	83 c4 10             	add    $0x10,%esp
8010177c:	eb 2f                	jmp    801017ad <ialloc+0xd4>
    }
    brelse(bp);
8010177e:	83 ec 0c             	sub    $0xc,%esp
80101781:	ff 75 f0             	push   -0x10(%ebp)
80101784:	e8 a6 ea ff ff       	call   8010022f <brelse>
80101789:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
8010178c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101790:	a1 a8 01 11 80       	mov    0x801101a8,%eax
80101795:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101798:	39 c2                	cmp    %eax,%edx
8010179a:	0f 82 52 ff ff ff    	jb     801016f2 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017a0:	83 ec 0c             	sub    $0xc,%esp
801017a3:	68 af 86 10 80       	push   $0x801086af
801017a8:	e8 cc ed ff ff       	call   80100579 <panic>
}
801017ad:	c9                   	leave
801017ae:	c3                   	ret

801017af <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801017af:	55                   	push   %ebp
801017b0:	89 e5                	mov    %esp,%ebp
801017b2:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017b5:	8b 45 08             	mov    0x8(%ebp),%eax
801017b8:	8b 40 04             	mov    0x4(%eax),%eax
801017bb:	c1 e8 03             	shr    $0x3,%eax
801017be:	89 c2                	mov    %eax,%edx
801017c0:	a1 b4 01 11 80       	mov    0x801101b4,%eax
801017c5:	01 c2                	add    %eax,%edx
801017c7:	8b 45 08             	mov    0x8(%ebp),%eax
801017ca:	8b 00                	mov    (%eax),%eax
801017cc:	83 ec 08             	sub    $0x8,%esp
801017cf:	52                   	push   %edx
801017d0:	50                   	push   %eax
801017d1:	e8 e1 e9 ff ff       	call   801001b7 <bread>
801017d6:	83 c4 10             	add    $0x10,%esp
801017d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017df:	8d 50 18             	lea    0x18(%eax),%edx
801017e2:	8b 45 08             	mov    0x8(%ebp),%eax
801017e5:	8b 40 04             	mov    0x4(%eax),%eax
801017e8:	83 e0 07             	and    $0x7,%eax
801017eb:	c1 e0 06             	shl    $0x6,%eax
801017ee:	01 d0                	add    %edx,%eax
801017f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801017f3:	8b 45 08             	mov    0x8(%ebp),%eax
801017f6:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801017fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017fd:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101800:	8b 45 08             	mov    0x8(%ebp),%eax
80101803:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101807:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010180a:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010180e:	8b 45 08             	mov    0x8(%ebp),%eax
80101811:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101815:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101818:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010181c:	8b 45 08             	mov    0x8(%ebp),%eax
8010181f:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101823:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101826:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010182a:	8b 45 08             	mov    0x8(%ebp),%eax
8010182d:	8b 50 18             	mov    0x18(%eax),%edx
80101830:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101833:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101836:	8b 45 08             	mov    0x8(%ebp),%eax
80101839:	8d 50 1c             	lea    0x1c(%eax),%edx
8010183c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010183f:	83 c0 0c             	add    $0xc,%eax
80101842:	83 ec 04             	sub    $0x4,%esp
80101845:	6a 34                	push   $0x34
80101847:	52                   	push   %edx
80101848:	50                   	push   %eax
80101849:	e8 37 3b 00 00       	call   80105385 <memmove>
8010184e:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101851:	83 ec 0c             	sub    $0xc,%esp
80101854:	ff 75 f4             	push   -0xc(%ebp)
80101857:	e8 33 1f 00 00       	call   8010378f <log_write>
8010185c:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010185f:	83 ec 0c             	sub    $0xc,%esp
80101862:	ff 75 f4             	push   -0xc(%ebp)
80101865:	e8 c5 e9 ff ff       	call   8010022f <brelse>
8010186a:	83 c4 10             	add    $0x10,%esp
}
8010186d:	90                   	nop
8010186e:	c9                   	leave
8010186f:	c3                   	ret

80101870 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101870:	55                   	push   %ebp
80101871:	89 e5                	mov    %esp,%ebp
80101873:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101876:	83 ec 0c             	sub    $0xc,%esp
80101879:	68 c0 01 11 80       	push   $0x801101c0
8010187e:	e8 df 37 00 00       	call   80105062 <acquire>
80101883:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101886:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010188d:	c7 45 f4 f4 01 11 80 	movl   $0x801101f4,-0xc(%ebp)
80101894:	eb 5d                	jmp    801018f3 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101899:	8b 40 08             	mov    0x8(%eax),%eax
8010189c:	85 c0                	test   %eax,%eax
8010189e:	7e 39                	jle    801018d9 <iget+0x69>
801018a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a3:	8b 00                	mov    (%eax),%eax
801018a5:	39 45 08             	cmp    %eax,0x8(%ebp)
801018a8:	75 2f                	jne    801018d9 <iget+0x69>
801018aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ad:	8b 40 04             	mov    0x4(%eax),%eax
801018b0:	39 45 0c             	cmp    %eax,0xc(%ebp)
801018b3:	75 24                	jne    801018d9 <iget+0x69>
      ip->ref++;
801018b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b8:	8b 40 08             	mov    0x8(%eax),%eax
801018bb:	8d 50 01             	lea    0x1(%eax),%edx
801018be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c1:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801018c4:	83 ec 0c             	sub    $0xc,%esp
801018c7:	68 c0 01 11 80       	push   $0x801101c0
801018cc:	e8 f8 37 00 00       	call   801050c9 <release>
801018d1:	83 c4 10             	add    $0x10,%esp
      return ip;
801018d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d7:	eb 74                	jmp    8010194d <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801018d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018dd:	75 10                	jne    801018ef <iget+0x7f>
801018df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e2:	8b 40 08             	mov    0x8(%eax),%eax
801018e5:	85 c0                	test   %eax,%eax
801018e7:	75 06                	jne    801018ef <iget+0x7f>
      empty = ip;
801018e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018ef:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801018f3:	81 7d f4 94 11 11 80 	cmpl   $0x80111194,-0xc(%ebp)
801018fa:	72 9a                	jb     80101896 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801018fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101900:	75 0d                	jne    8010190f <iget+0x9f>
    panic("iget: no inodes");
80101902:	83 ec 0c             	sub    $0xc,%esp
80101905:	68 c1 86 10 80       	push   $0x801086c1
8010190a:	e8 6a ec ff ff       	call   80100579 <panic>

  ip = empty;
8010190f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101912:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101918:	8b 55 08             	mov    0x8(%ebp),%edx
8010191b:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010191d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101920:	8b 55 0c             	mov    0xc(%ebp),%edx
80101923:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101929:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101933:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
8010193a:	83 ec 0c             	sub    $0xc,%esp
8010193d:	68 c0 01 11 80       	push   $0x801101c0
80101942:	e8 82 37 00 00       	call   801050c9 <release>
80101947:	83 c4 10             	add    $0x10,%esp

  return ip;
8010194a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010194d:	c9                   	leave
8010194e:	c3                   	ret

8010194f <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
8010194f:	55                   	push   %ebp
80101950:	89 e5                	mov    %esp,%ebp
80101952:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101955:	83 ec 0c             	sub    $0xc,%esp
80101958:	68 c0 01 11 80       	push   $0x801101c0
8010195d:	e8 00 37 00 00       	call   80105062 <acquire>
80101962:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101965:	8b 45 08             	mov    0x8(%ebp),%eax
80101968:	8b 40 08             	mov    0x8(%eax),%eax
8010196b:	8d 50 01             	lea    0x1(%eax),%edx
8010196e:	8b 45 08             	mov    0x8(%ebp),%eax
80101971:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101974:	83 ec 0c             	sub    $0xc,%esp
80101977:	68 c0 01 11 80       	push   $0x801101c0
8010197c:	e8 48 37 00 00       	call   801050c9 <release>
80101981:	83 c4 10             	add    $0x10,%esp
  return ip;
80101984:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101987:	c9                   	leave
80101988:	c3                   	ret

80101989 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101989:	55                   	push   %ebp
8010198a:	89 e5                	mov    %esp,%ebp
8010198c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
8010198f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101993:	74 0a                	je     8010199f <ilock+0x16>
80101995:	8b 45 08             	mov    0x8(%ebp),%eax
80101998:	8b 40 08             	mov    0x8(%eax),%eax
8010199b:	85 c0                	test   %eax,%eax
8010199d:	7f 0d                	jg     801019ac <ilock+0x23>
    panic("ilock");
8010199f:	83 ec 0c             	sub    $0xc,%esp
801019a2:	68 d1 86 10 80       	push   $0x801086d1
801019a7:	e8 cd eb ff ff       	call   80100579 <panic>

  acquire(&icache.lock);
801019ac:	83 ec 0c             	sub    $0xc,%esp
801019af:	68 c0 01 11 80       	push   $0x801101c0
801019b4:	e8 a9 36 00 00       	call   80105062 <acquire>
801019b9:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
801019bc:	eb 13                	jmp    801019d1 <ilock+0x48>
    sleep(ip, &icache.lock);
801019be:	83 ec 08             	sub    $0x8,%esp
801019c1:	68 c0 01 11 80       	push   $0x801101c0
801019c6:	ff 75 08             	push   0x8(%ebp)
801019c9:	e8 99 33 00 00       	call   80104d67 <sleep>
801019ce:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
801019d1:	8b 45 08             	mov    0x8(%ebp),%eax
801019d4:	8b 40 0c             	mov    0xc(%eax),%eax
801019d7:	83 e0 01             	and    $0x1,%eax
801019da:	85 c0                	test   %eax,%eax
801019dc:	75 e0                	jne    801019be <ilock+0x35>
  ip->flags |= I_BUSY;
801019de:	8b 45 08             	mov    0x8(%ebp),%eax
801019e1:	8b 40 0c             	mov    0xc(%eax),%eax
801019e4:	83 c8 01             	or     $0x1,%eax
801019e7:	89 c2                	mov    %eax,%edx
801019e9:	8b 45 08             	mov    0x8(%ebp),%eax
801019ec:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801019ef:	83 ec 0c             	sub    $0xc,%esp
801019f2:	68 c0 01 11 80       	push   $0x801101c0
801019f7:	e8 cd 36 00 00       	call   801050c9 <release>
801019fc:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
801019ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101a02:	8b 40 0c             	mov    0xc(%eax),%eax
80101a05:	83 e0 02             	and    $0x2,%eax
80101a08:	85 c0                	test   %eax,%eax
80101a0a:	0f 85 d4 00 00 00    	jne    80101ae4 <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a10:	8b 45 08             	mov    0x8(%ebp),%eax
80101a13:	8b 40 04             	mov    0x4(%eax),%eax
80101a16:	c1 e8 03             	shr    $0x3,%eax
80101a19:	89 c2                	mov    %eax,%edx
80101a1b:	a1 b4 01 11 80       	mov    0x801101b4,%eax
80101a20:	01 c2                	add    %eax,%edx
80101a22:	8b 45 08             	mov    0x8(%ebp),%eax
80101a25:	8b 00                	mov    (%eax),%eax
80101a27:	83 ec 08             	sub    $0x8,%esp
80101a2a:	52                   	push   %edx
80101a2b:	50                   	push   %eax
80101a2c:	e8 86 e7 ff ff       	call   801001b7 <bread>
80101a31:	83 c4 10             	add    $0x10,%esp
80101a34:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3a:	8d 50 18             	lea    0x18(%eax),%edx
80101a3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a40:	8b 40 04             	mov    0x4(%eax),%eax
80101a43:	83 e0 07             	and    $0x7,%eax
80101a46:	c1 e0 06             	shl    $0x6,%eax
80101a49:	01 d0                	add    %edx,%eax
80101a4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a51:	0f b7 10             	movzwl (%eax),%edx
80101a54:	8b 45 08             	mov    0x8(%ebp),%eax
80101a57:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101a5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a5e:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a62:	8b 45 08             	mov    0x8(%ebp),%eax
80101a65:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6c:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a70:	8b 45 08             	mov    0x8(%ebp),%eax
80101a73:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7a:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a81:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a88:	8b 50 08             	mov    0x8(%eax),%edx
80101a8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8e:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a94:	8d 50 0c             	lea    0xc(%eax),%edx
80101a97:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9a:	83 c0 1c             	add    $0x1c,%eax
80101a9d:	83 ec 04             	sub    $0x4,%esp
80101aa0:	6a 34                	push   $0x34
80101aa2:	52                   	push   %edx
80101aa3:	50                   	push   %eax
80101aa4:	e8 dc 38 00 00       	call   80105385 <memmove>
80101aa9:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101aac:	83 ec 0c             	sub    $0xc,%esp
80101aaf:	ff 75 f4             	push   -0xc(%ebp)
80101ab2:	e8 78 e7 ff ff       	call   8010022f <brelse>
80101ab7:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101aba:	8b 45 08             	mov    0x8(%ebp),%eax
80101abd:	8b 40 0c             	mov    0xc(%eax),%eax
80101ac0:	83 c8 02             	or     $0x2,%eax
80101ac3:	89 c2                	mov    %eax,%edx
80101ac5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac8:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101acb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ace:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ad2:	66 85 c0             	test   %ax,%ax
80101ad5:	75 0d                	jne    80101ae4 <ilock+0x15b>
      panic("ilock: no type");
80101ad7:	83 ec 0c             	sub    $0xc,%esp
80101ada:	68 d7 86 10 80       	push   $0x801086d7
80101adf:	e8 95 ea ff ff       	call   80100579 <panic>
  }
}
80101ae4:	90                   	nop
80101ae5:	c9                   	leave
80101ae6:	c3                   	ret

80101ae7 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101ae7:	55                   	push   %ebp
80101ae8:	89 e5                	mov    %esp,%ebp
80101aea:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101aed:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101af1:	74 17                	je     80101b0a <iunlock+0x23>
80101af3:	8b 45 08             	mov    0x8(%ebp),%eax
80101af6:	8b 40 0c             	mov    0xc(%eax),%eax
80101af9:	83 e0 01             	and    $0x1,%eax
80101afc:	85 c0                	test   %eax,%eax
80101afe:	74 0a                	je     80101b0a <iunlock+0x23>
80101b00:	8b 45 08             	mov    0x8(%ebp),%eax
80101b03:	8b 40 08             	mov    0x8(%eax),%eax
80101b06:	85 c0                	test   %eax,%eax
80101b08:	7f 0d                	jg     80101b17 <iunlock+0x30>
    panic("iunlock");
80101b0a:	83 ec 0c             	sub    $0xc,%esp
80101b0d:	68 e6 86 10 80       	push   $0x801086e6
80101b12:	e8 62 ea ff ff       	call   80100579 <panic>

  acquire(&icache.lock);
80101b17:	83 ec 0c             	sub    $0xc,%esp
80101b1a:	68 c0 01 11 80       	push   $0x801101c0
80101b1f:	e8 3e 35 00 00       	call   80105062 <acquire>
80101b24:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101b27:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2a:	8b 40 0c             	mov    0xc(%eax),%eax
80101b2d:	83 e0 fe             	and    $0xfffffffe,%eax
80101b30:	89 c2                	mov    %eax,%edx
80101b32:	8b 45 08             	mov    0x8(%ebp),%eax
80101b35:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101b38:	83 ec 0c             	sub    $0xc,%esp
80101b3b:	ff 75 08             	push   0x8(%ebp)
80101b3e:	e8 10 33 00 00       	call   80104e53 <wakeup>
80101b43:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101b46:	83 ec 0c             	sub    $0xc,%esp
80101b49:	68 c0 01 11 80       	push   $0x801101c0
80101b4e:	e8 76 35 00 00       	call   801050c9 <release>
80101b53:	83 c4 10             	add    $0x10,%esp
}
80101b56:	90                   	nop
80101b57:	c9                   	leave
80101b58:	c3                   	ret

80101b59 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b59:	55                   	push   %ebp
80101b5a:	89 e5                	mov    %esp,%ebp
80101b5c:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b5f:	83 ec 0c             	sub    $0xc,%esp
80101b62:	68 c0 01 11 80       	push   $0x801101c0
80101b67:	e8 f6 34 00 00       	call   80105062 <acquire>
80101b6c:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101b6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b72:	8b 40 08             	mov    0x8(%eax),%eax
80101b75:	83 f8 01             	cmp    $0x1,%eax
80101b78:	0f 85 a9 00 00 00    	jne    80101c27 <iput+0xce>
80101b7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b81:	8b 40 0c             	mov    0xc(%eax),%eax
80101b84:	83 e0 02             	and    $0x2,%eax
80101b87:	85 c0                	test   %eax,%eax
80101b89:	0f 84 98 00 00 00    	je     80101c27 <iput+0xce>
80101b8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b92:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b96:	66 85 c0             	test   %ax,%ax
80101b99:	0f 85 88 00 00 00    	jne    80101c27 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba2:	8b 40 0c             	mov    0xc(%eax),%eax
80101ba5:	83 e0 01             	and    $0x1,%eax
80101ba8:	85 c0                	test   %eax,%eax
80101baa:	74 0d                	je     80101bb9 <iput+0x60>
      panic("iput busy");
80101bac:	83 ec 0c             	sub    $0xc,%esp
80101baf:	68 ee 86 10 80       	push   $0x801086ee
80101bb4:	e8 c0 e9 ff ff       	call   80100579 <panic>
    ip->flags |= I_BUSY;
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 0c             	mov    0xc(%eax),%eax
80101bbf:	83 c8 01             	or     $0x1,%eax
80101bc2:	89 c2                	mov    %eax,%edx
80101bc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc7:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101bca:	83 ec 0c             	sub    $0xc,%esp
80101bcd:	68 c0 01 11 80       	push   $0x801101c0
80101bd2:	e8 f2 34 00 00       	call   801050c9 <release>
80101bd7:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101bda:	83 ec 0c             	sub    $0xc,%esp
80101bdd:	ff 75 08             	push   0x8(%ebp)
80101be0:	e8 a3 01 00 00       	call   80101d88 <itrunc>
80101be5:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101be8:	8b 45 08             	mov    0x8(%ebp),%eax
80101beb:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101bf1:	83 ec 0c             	sub    $0xc,%esp
80101bf4:	ff 75 08             	push   0x8(%ebp)
80101bf7:	e8 b3 fb ff ff       	call   801017af <iupdate>
80101bfc:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101bff:	83 ec 0c             	sub    $0xc,%esp
80101c02:	68 c0 01 11 80       	push   $0x801101c0
80101c07:	e8 56 34 00 00       	call   80105062 <acquire>
80101c0c:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101c0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c12:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101c19:	83 ec 0c             	sub    $0xc,%esp
80101c1c:	ff 75 08             	push   0x8(%ebp)
80101c1f:	e8 2f 32 00 00       	call   80104e53 <wakeup>
80101c24:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 40 08             	mov    0x8(%eax),%eax
80101c2d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c30:	8b 45 08             	mov    0x8(%ebp),%eax
80101c33:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c36:	83 ec 0c             	sub    $0xc,%esp
80101c39:	68 c0 01 11 80       	push   $0x801101c0
80101c3e:	e8 86 34 00 00       	call   801050c9 <release>
80101c43:	83 c4 10             	add    $0x10,%esp
}
80101c46:	90                   	nop
80101c47:	c9                   	leave
80101c48:	c3                   	ret

80101c49 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c49:	55                   	push   %ebp
80101c4a:	89 e5                	mov    %esp,%ebp
80101c4c:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c4f:	83 ec 0c             	sub    $0xc,%esp
80101c52:	ff 75 08             	push   0x8(%ebp)
80101c55:	e8 8d fe ff ff       	call   80101ae7 <iunlock>
80101c5a:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c5d:	83 ec 0c             	sub    $0xc,%esp
80101c60:	ff 75 08             	push   0x8(%ebp)
80101c63:	e8 f1 fe ff ff       	call   80101b59 <iput>
80101c68:	83 c4 10             	add    $0x10,%esp
}
80101c6b:	90                   	nop
80101c6c:	c9                   	leave
80101c6d:	c3                   	ret

80101c6e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c6e:	55                   	push   %ebp
80101c6f:	89 e5                	mov    %esp,%ebp
80101c71:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c74:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c78:	77 42                	ja     80101cbc <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c80:	83 c2 04             	add    $0x4,%edx
80101c83:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c87:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c8a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c8e:	75 24                	jne    80101cb4 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c90:	8b 45 08             	mov    0x8(%ebp),%eax
80101c93:	8b 00                	mov    (%eax),%eax
80101c95:	83 ec 0c             	sub    $0xc,%esp
80101c98:	50                   	push   %eax
80101c99:	e8 ad f7 ff ff       	call   8010144b <balloc>
80101c9e:	83 c4 10             	add    $0x10,%esp
80101ca1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101caa:	8d 4a 04             	lea    0x4(%edx),%ecx
80101cad:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cb0:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cb7:	e9 ca 00 00 00       	jmp    80101d86 <bmap+0x118>
  }
  bn -= NDIRECT;
80101cbc:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101cc0:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101cc4:	0f 87 af 00 00 00    	ja     80101d79 <bmap+0x10b>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101cca:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccd:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cd3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cd7:	75 1d                	jne    80101cf6 <bmap+0x88>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cd9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdc:	8b 00                	mov    (%eax),%eax
80101cde:	83 ec 0c             	sub    $0xc,%esp
80101ce1:	50                   	push   %eax
80101ce2:	e8 64 f7 ff ff       	call   8010144b <balloc>
80101ce7:	83 c4 10             	add    $0x10,%esp
80101cea:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ced:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cf3:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf9:	8b 00                	mov    (%eax),%eax
80101cfb:	83 ec 08             	sub    $0x8,%esp
80101cfe:	ff 75 f4             	push   -0xc(%ebp)
80101d01:	50                   	push   %eax
80101d02:	e8 b0 e4 ff ff       	call   801001b7 <bread>
80101d07:	83 c4 10             	add    $0x10,%esp
80101d0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d10:	83 c0 18             	add    $0x18,%eax
80101d13:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d16:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d19:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d23:	01 d0                	add    %edx,%eax
80101d25:	8b 00                	mov    (%eax),%eax
80101d27:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d2a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d2e:	75 36                	jne    80101d66 <bmap+0xf8>
      a[bn] = addr = balloc(ip->dev);
80101d30:	8b 45 08             	mov    0x8(%ebp),%eax
80101d33:	8b 00                	mov    (%eax),%eax
80101d35:	83 ec 0c             	sub    $0xc,%esp
80101d38:	50                   	push   %eax
80101d39:	e8 0d f7 ff ff       	call   8010144b <balloc>
80101d3e:	83 c4 10             	add    $0x10,%esp
80101d41:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d44:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d47:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d51:	01 c2                	add    %eax,%edx
80101d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d56:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d58:	83 ec 0c             	sub    $0xc,%esp
80101d5b:	ff 75 f0             	push   -0x10(%ebp)
80101d5e:	e8 2c 1a 00 00       	call   8010378f <log_write>
80101d63:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d66:	83 ec 0c             	sub    $0xc,%esp
80101d69:	ff 75 f0             	push   -0x10(%ebp)
80101d6c:	e8 be e4 ff ff       	call   8010022f <brelse>
80101d71:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d77:	eb 0d                	jmp    80101d86 <bmap+0x118>
  }

  panic("bmap: out of range");
80101d79:	83 ec 0c             	sub    $0xc,%esp
80101d7c:	68 f8 86 10 80       	push   $0x801086f8
80101d81:	e8 f3 e7 ff ff       	call   80100579 <panic>
}
80101d86:	c9                   	leave
80101d87:	c3                   	ret

80101d88 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d88:	55                   	push   %ebp
80101d89:	89 e5                	mov    %esp,%ebp
80101d8b:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d8e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d95:	eb 45                	jmp    80101ddc <itrunc+0x54>
    if(ip->addrs[i]){
80101d97:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d9d:	83 c2 04             	add    $0x4,%edx
80101da0:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101da4:	85 c0                	test   %eax,%eax
80101da6:	74 30                	je     80101dd8 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101da8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dab:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dae:	83 c2 04             	add    $0x4,%edx
80101db1:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101db5:	8b 55 08             	mov    0x8(%ebp),%edx
80101db8:	8b 12                	mov    (%edx),%edx
80101dba:	83 ec 08             	sub    $0x8,%esp
80101dbd:	50                   	push   %eax
80101dbe:	52                   	push   %edx
80101dbf:	e8 ca f7 ff ff       	call   8010158e <bfree>
80101dc4:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101dc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101dca:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dcd:	83 c2 04             	add    $0x4,%edx
80101dd0:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101dd7:	00 
  for(i = 0; i < NDIRECT; i++){
80101dd8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101ddc:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101de0:	7e b5                	jle    80101d97 <itrunc+0xf>
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101de2:	8b 45 08             	mov    0x8(%ebp),%eax
80101de5:	8b 40 4c             	mov    0x4c(%eax),%eax
80101de8:	85 c0                	test   %eax,%eax
80101dea:	0f 84 a1 00 00 00    	je     80101e91 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101df0:	8b 45 08             	mov    0x8(%ebp),%eax
80101df3:	8b 50 4c             	mov    0x4c(%eax),%edx
80101df6:	8b 45 08             	mov    0x8(%ebp),%eax
80101df9:	8b 00                	mov    (%eax),%eax
80101dfb:	83 ec 08             	sub    $0x8,%esp
80101dfe:	52                   	push   %edx
80101dff:	50                   	push   %eax
80101e00:	e8 b2 e3 ff ff       	call   801001b7 <bread>
80101e05:	83 c4 10             	add    $0x10,%esp
80101e08:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e0e:	83 c0 18             	add    $0x18,%eax
80101e11:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e14:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e1b:	eb 3c                	jmp    80101e59 <itrunc+0xd1>
      if(a[j])
80101e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e20:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e27:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e2a:	01 d0                	add    %edx,%eax
80101e2c:	8b 00                	mov    (%eax),%eax
80101e2e:	85 c0                	test   %eax,%eax
80101e30:	74 23                	je     80101e55 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101e32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e35:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e3f:	01 d0                	add    %edx,%eax
80101e41:	8b 00                	mov    (%eax),%eax
80101e43:	8b 55 08             	mov    0x8(%ebp),%edx
80101e46:	8b 12                	mov    (%edx),%edx
80101e48:	83 ec 08             	sub    $0x8,%esp
80101e4b:	50                   	push   %eax
80101e4c:	52                   	push   %edx
80101e4d:	e8 3c f7 ff ff       	call   8010158e <bfree>
80101e52:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e55:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e5c:	83 f8 7f             	cmp    $0x7f,%eax
80101e5f:	76 bc                	jbe    80101e1d <itrunc+0x95>
    }
    brelse(bp);
80101e61:	83 ec 0c             	sub    $0xc,%esp
80101e64:	ff 75 ec             	push   -0x14(%ebp)
80101e67:	e8 c3 e3 ff ff       	call   8010022f <brelse>
80101e6c:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e72:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e75:	8b 55 08             	mov    0x8(%ebp),%edx
80101e78:	8b 12                	mov    (%edx),%edx
80101e7a:	83 ec 08             	sub    $0x8,%esp
80101e7d:	50                   	push   %eax
80101e7e:	52                   	push   %edx
80101e7f:	e8 0a f7 ff ff       	call   8010158e <bfree>
80101e84:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e87:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8a:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e91:	8b 45 08             	mov    0x8(%ebp),%eax
80101e94:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e9b:	83 ec 0c             	sub    $0xc,%esp
80101e9e:	ff 75 08             	push   0x8(%ebp)
80101ea1:	e8 09 f9 ff ff       	call   801017af <iupdate>
80101ea6:	83 c4 10             	add    $0x10,%esp
}
80101ea9:	90                   	nop
80101eaa:	c9                   	leave
80101eab:	c3                   	ret

80101eac <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101eac:	55                   	push   %ebp
80101ead:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb2:	8b 00                	mov    (%eax),%eax
80101eb4:	89 c2                	mov    %eax,%edx
80101eb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb9:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ebc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebf:	8b 50 04             	mov    0x4(%eax),%edx
80101ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec5:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecb:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed2:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ed5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed8:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101edc:	8b 45 0c             	mov    0xc(%ebp),%eax
80101edf:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ee3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee6:	8b 50 18             	mov    0x18(%eax),%edx
80101ee9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eec:	89 50 10             	mov    %edx,0x10(%eax)
}
80101eef:	90                   	nop
80101ef0:	5d                   	pop    %ebp
80101ef1:	c3                   	ret

80101ef2 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ef2:	55                   	push   %ebp
80101ef3:	89 e5                	mov    %esp,%ebp
80101ef5:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80101efb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101eff:	66 83 f8 03          	cmp    $0x3,%ax
80101f03:	75 5c                	jne    80101f61 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f05:	8b 45 08             	mov    0x8(%ebp),%eax
80101f08:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f0c:	66 85 c0             	test   %ax,%ax
80101f0f:	78 20                	js     80101f31 <readi+0x3f>
80101f11:	8b 45 08             	mov    0x8(%ebp),%eax
80101f14:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f18:	66 83 f8 09          	cmp    $0x9,%ax
80101f1c:	7f 13                	jg     80101f31 <readi+0x3f>
80101f1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f21:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f25:	98                   	cwtl
80101f26:	8b 04 c5 a0 f7 10 80 	mov    -0x7fef0860(,%eax,8),%eax
80101f2d:	85 c0                	test   %eax,%eax
80101f2f:	75 0a                	jne    80101f3b <readi+0x49>
      return -1;
80101f31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f36:	e9 0a 01 00 00       	jmp    80102045 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f42:	98                   	cwtl
80101f43:	8b 04 c5 a0 f7 10 80 	mov    -0x7fef0860(,%eax,8),%eax
80101f4a:	8b 55 14             	mov    0x14(%ebp),%edx
80101f4d:	83 ec 04             	sub    $0x4,%esp
80101f50:	52                   	push   %edx
80101f51:	ff 75 0c             	push   0xc(%ebp)
80101f54:	ff 75 08             	push   0x8(%ebp)
80101f57:	ff d0                	call   *%eax
80101f59:	83 c4 10             	add    $0x10,%esp
80101f5c:	e9 e4 00 00 00       	jmp    80102045 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f61:	8b 45 08             	mov    0x8(%ebp),%eax
80101f64:	8b 40 18             	mov    0x18(%eax),%eax
80101f67:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f6a:	72 0d                	jb     80101f79 <readi+0x87>
80101f6c:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6f:	8b 45 14             	mov    0x14(%ebp),%eax
80101f72:	01 d0                	add    %edx,%eax
80101f74:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f77:	73 0a                	jae    80101f83 <readi+0x91>
    return -1;
80101f79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f7e:	e9 c2 00 00 00       	jmp    80102045 <readi+0x153>
  if(off + n > ip->size)
80101f83:	8b 55 10             	mov    0x10(%ebp),%edx
80101f86:	8b 45 14             	mov    0x14(%ebp),%eax
80101f89:	01 c2                	add    %eax,%edx
80101f8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8e:	8b 40 18             	mov    0x18(%eax),%eax
80101f91:	39 d0                	cmp    %edx,%eax
80101f93:	73 0c                	jae    80101fa1 <readi+0xaf>
    n = ip->size - off;
80101f95:	8b 45 08             	mov    0x8(%ebp),%eax
80101f98:	8b 40 18             	mov    0x18(%eax),%eax
80101f9b:	2b 45 10             	sub    0x10(%ebp),%eax
80101f9e:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101fa1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fa8:	e9 89 00 00 00       	jmp    80102036 <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101fad:	8b 45 10             	mov    0x10(%ebp),%eax
80101fb0:	c1 e8 09             	shr    $0x9,%eax
80101fb3:	83 ec 08             	sub    $0x8,%esp
80101fb6:	50                   	push   %eax
80101fb7:	ff 75 08             	push   0x8(%ebp)
80101fba:	e8 af fc ff ff       	call   80101c6e <bmap>
80101fbf:	83 c4 10             	add    $0x10,%esp
80101fc2:	8b 55 08             	mov    0x8(%ebp),%edx
80101fc5:	8b 12                	mov    (%edx),%edx
80101fc7:	83 ec 08             	sub    $0x8,%esp
80101fca:	50                   	push   %eax
80101fcb:	52                   	push   %edx
80101fcc:	e8 e6 e1 ff ff       	call   801001b7 <bread>
80101fd1:	83 c4 10             	add    $0x10,%esp
80101fd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fd7:	8b 45 10             	mov    0x10(%ebp),%eax
80101fda:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fdf:	ba 00 02 00 00       	mov    $0x200,%edx
80101fe4:	29 c2                	sub    %eax,%edx
80101fe6:	8b 45 14             	mov    0x14(%ebp),%eax
80101fe9:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fec:	39 c2                	cmp    %eax,%edx
80101fee:	0f 46 c2             	cmovbe %edx,%eax
80101ff1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101ff4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ff7:	8d 50 18             	lea    0x18(%eax),%edx
80101ffa:	8b 45 10             	mov    0x10(%ebp),%eax
80101ffd:	25 ff 01 00 00       	and    $0x1ff,%eax
80102002:	01 d0                	add    %edx,%eax
80102004:	83 ec 04             	sub    $0x4,%esp
80102007:	ff 75 ec             	push   -0x14(%ebp)
8010200a:	50                   	push   %eax
8010200b:	ff 75 0c             	push   0xc(%ebp)
8010200e:	e8 72 33 00 00       	call   80105385 <memmove>
80102013:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102016:	83 ec 0c             	sub    $0xc,%esp
80102019:	ff 75 f0             	push   -0x10(%ebp)
8010201c:	e8 0e e2 ff ff       	call   8010022f <brelse>
80102021:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102024:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102027:	01 45 f4             	add    %eax,-0xc(%ebp)
8010202a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010202d:	01 45 10             	add    %eax,0x10(%ebp)
80102030:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102033:	01 45 0c             	add    %eax,0xc(%ebp)
80102036:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102039:	3b 45 14             	cmp    0x14(%ebp),%eax
8010203c:	0f 82 6b ff ff ff    	jb     80101fad <readi+0xbb>
  }
  return n;
80102042:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102045:	c9                   	leave
80102046:	c3                   	ret

80102047 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102047:	55                   	push   %ebp
80102048:	89 e5                	mov    %esp,%ebp
8010204a:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010204d:	8b 45 08             	mov    0x8(%ebp),%eax
80102050:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102054:	66 83 f8 03          	cmp    $0x3,%ax
80102058:	75 5c                	jne    801020b6 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010205a:	8b 45 08             	mov    0x8(%ebp),%eax
8010205d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102061:	66 85 c0             	test   %ax,%ax
80102064:	78 20                	js     80102086 <writei+0x3f>
80102066:	8b 45 08             	mov    0x8(%ebp),%eax
80102069:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010206d:	66 83 f8 09          	cmp    $0x9,%ax
80102071:	7f 13                	jg     80102086 <writei+0x3f>
80102073:	8b 45 08             	mov    0x8(%ebp),%eax
80102076:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010207a:	98                   	cwtl
8010207b:	8b 04 c5 a4 f7 10 80 	mov    -0x7fef085c(,%eax,8),%eax
80102082:	85 c0                	test   %eax,%eax
80102084:	75 0a                	jne    80102090 <writei+0x49>
      return -1;
80102086:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010208b:	e9 3b 01 00 00       	jmp    801021cb <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102090:	8b 45 08             	mov    0x8(%ebp),%eax
80102093:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102097:	98                   	cwtl
80102098:	8b 04 c5 a4 f7 10 80 	mov    -0x7fef085c(,%eax,8),%eax
8010209f:	8b 55 14             	mov    0x14(%ebp),%edx
801020a2:	83 ec 04             	sub    $0x4,%esp
801020a5:	52                   	push   %edx
801020a6:	ff 75 0c             	push   0xc(%ebp)
801020a9:	ff 75 08             	push   0x8(%ebp)
801020ac:	ff d0                	call   *%eax
801020ae:	83 c4 10             	add    $0x10,%esp
801020b1:	e9 15 01 00 00       	jmp    801021cb <writei+0x184>
  }

  if(off > ip->size || off + n < off)
801020b6:	8b 45 08             	mov    0x8(%ebp),%eax
801020b9:	8b 40 18             	mov    0x18(%eax),%eax
801020bc:	3b 45 10             	cmp    0x10(%ebp),%eax
801020bf:	72 0d                	jb     801020ce <writei+0x87>
801020c1:	8b 55 10             	mov    0x10(%ebp),%edx
801020c4:	8b 45 14             	mov    0x14(%ebp),%eax
801020c7:	01 d0                	add    %edx,%eax
801020c9:	3b 45 10             	cmp    0x10(%ebp),%eax
801020cc:	73 0a                	jae    801020d8 <writei+0x91>
    return -1;
801020ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d3:	e9 f3 00 00 00       	jmp    801021cb <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020d8:	8b 55 10             	mov    0x10(%ebp),%edx
801020db:	8b 45 14             	mov    0x14(%ebp),%eax
801020de:	01 d0                	add    %edx,%eax
801020e0:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020e5:	76 0a                	jbe    801020f1 <writei+0xaa>
    return -1;
801020e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020ec:	e9 da 00 00 00       	jmp    801021cb <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020f8:	e9 97 00 00 00       	jmp    80102194 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020fd:	8b 45 10             	mov    0x10(%ebp),%eax
80102100:	c1 e8 09             	shr    $0x9,%eax
80102103:	83 ec 08             	sub    $0x8,%esp
80102106:	50                   	push   %eax
80102107:	ff 75 08             	push   0x8(%ebp)
8010210a:	e8 5f fb ff ff       	call   80101c6e <bmap>
8010210f:	83 c4 10             	add    $0x10,%esp
80102112:	8b 55 08             	mov    0x8(%ebp),%edx
80102115:	8b 12                	mov    (%edx),%edx
80102117:	83 ec 08             	sub    $0x8,%esp
8010211a:	50                   	push   %eax
8010211b:	52                   	push   %edx
8010211c:	e8 96 e0 ff ff       	call   801001b7 <bread>
80102121:	83 c4 10             	add    $0x10,%esp
80102124:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102127:	8b 45 10             	mov    0x10(%ebp),%eax
8010212a:	25 ff 01 00 00       	and    $0x1ff,%eax
8010212f:	ba 00 02 00 00       	mov    $0x200,%edx
80102134:	29 c2                	sub    %eax,%edx
80102136:	8b 45 14             	mov    0x14(%ebp),%eax
80102139:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010213c:	39 c2                	cmp    %eax,%edx
8010213e:	0f 46 c2             	cmovbe %edx,%eax
80102141:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102144:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102147:	8d 50 18             	lea    0x18(%eax),%edx
8010214a:	8b 45 10             	mov    0x10(%ebp),%eax
8010214d:	25 ff 01 00 00       	and    $0x1ff,%eax
80102152:	01 d0                	add    %edx,%eax
80102154:	83 ec 04             	sub    $0x4,%esp
80102157:	ff 75 ec             	push   -0x14(%ebp)
8010215a:	ff 75 0c             	push   0xc(%ebp)
8010215d:	50                   	push   %eax
8010215e:	e8 22 32 00 00       	call   80105385 <memmove>
80102163:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102166:	83 ec 0c             	sub    $0xc,%esp
80102169:	ff 75 f0             	push   -0x10(%ebp)
8010216c:	e8 1e 16 00 00       	call   8010378f <log_write>
80102171:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102174:	83 ec 0c             	sub    $0xc,%esp
80102177:	ff 75 f0             	push   -0x10(%ebp)
8010217a:	e8 b0 e0 ff ff       	call   8010022f <brelse>
8010217f:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102182:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102185:	01 45 f4             	add    %eax,-0xc(%ebp)
80102188:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010218b:	01 45 10             	add    %eax,0x10(%ebp)
8010218e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102191:	01 45 0c             	add    %eax,0xc(%ebp)
80102194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102197:	3b 45 14             	cmp    0x14(%ebp),%eax
8010219a:	0f 82 5d ff ff ff    	jb     801020fd <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
801021a0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801021a4:	74 22                	je     801021c8 <writei+0x181>
801021a6:	8b 45 08             	mov    0x8(%ebp),%eax
801021a9:	8b 40 18             	mov    0x18(%eax),%eax
801021ac:	3b 45 10             	cmp    0x10(%ebp),%eax
801021af:	73 17                	jae    801021c8 <writei+0x181>
    ip->size = off;
801021b1:	8b 45 08             	mov    0x8(%ebp),%eax
801021b4:	8b 55 10             	mov    0x10(%ebp),%edx
801021b7:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801021ba:	83 ec 0c             	sub    $0xc,%esp
801021bd:	ff 75 08             	push   0x8(%ebp)
801021c0:	e8 ea f5 ff ff       	call   801017af <iupdate>
801021c5:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021c8:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021cb:	c9                   	leave
801021cc:	c3                   	ret

801021cd <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021cd:	55                   	push   %ebp
801021ce:	89 e5                	mov    %esp,%ebp
801021d0:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021d3:	83 ec 04             	sub    $0x4,%esp
801021d6:	6a 0e                	push   $0xe
801021d8:	ff 75 0c             	push   0xc(%ebp)
801021db:	ff 75 08             	push   0x8(%ebp)
801021de:	e8 38 32 00 00       	call   8010541b <strncmp>
801021e3:	83 c4 10             	add    $0x10,%esp
}
801021e6:	c9                   	leave
801021e7:	c3                   	ret

801021e8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021e8:	55                   	push   %ebp
801021e9:	89 e5                	mov    %esp,%ebp
801021eb:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021ee:	8b 45 08             	mov    0x8(%ebp),%eax
801021f1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021f5:	66 83 f8 01          	cmp    $0x1,%ax
801021f9:	74 0d                	je     80102208 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021fb:	83 ec 0c             	sub    $0xc,%esp
801021fe:	68 0b 87 10 80       	push   $0x8010870b
80102203:	e8 71 e3 ff ff       	call   80100579 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102208:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010220f:	eb 7b                	jmp    8010228c <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102211:	6a 10                	push   $0x10
80102213:	ff 75 f4             	push   -0xc(%ebp)
80102216:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102219:	50                   	push   %eax
8010221a:	ff 75 08             	push   0x8(%ebp)
8010221d:	e8 d0 fc ff ff       	call   80101ef2 <readi>
80102222:	83 c4 10             	add    $0x10,%esp
80102225:	83 f8 10             	cmp    $0x10,%eax
80102228:	74 0d                	je     80102237 <dirlookup+0x4f>
      panic("dirlink read");
8010222a:	83 ec 0c             	sub    $0xc,%esp
8010222d:	68 1d 87 10 80       	push   $0x8010871d
80102232:	e8 42 e3 ff ff       	call   80100579 <panic>
    if(de.inum == 0)
80102237:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010223b:	66 85 c0             	test   %ax,%ax
8010223e:	74 47                	je     80102287 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102240:	83 ec 08             	sub    $0x8,%esp
80102243:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102246:	83 c0 02             	add    $0x2,%eax
80102249:	50                   	push   %eax
8010224a:	ff 75 0c             	push   0xc(%ebp)
8010224d:	e8 7b ff ff ff       	call   801021cd <namecmp>
80102252:	83 c4 10             	add    $0x10,%esp
80102255:	85 c0                	test   %eax,%eax
80102257:	75 2f                	jne    80102288 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102259:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010225d:	74 08                	je     80102267 <dirlookup+0x7f>
        *poff = off;
8010225f:	8b 45 10             	mov    0x10(%ebp),%eax
80102262:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102265:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102267:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010226b:	0f b7 c0             	movzwl %ax,%eax
8010226e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102271:	8b 45 08             	mov    0x8(%ebp),%eax
80102274:	8b 00                	mov    (%eax),%eax
80102276:	83 ec 08             	sub    $0x8,%esp
80102279:	ff 75 f0             	push   -0x10(%ebp)
8010227c:	50                   	push   %eax
8010227d:	e8 ee f5 ff ff       	call   80101870 <iget>
80102282:	83 c4 10             	add    $0x10,%esp
80102285:	eb 19                	jmp    801022a0 <dirlookup+0xb8>
      continue;
80102287:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102288:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010228c:	8b 45 08             	mov    0x8(%ebp),%eax
8010228f:	8b 40 18             	mov    0x18(%eax),%eax
80102292:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102295:	0f 82 76 ff ff ff    	jb     80102211 <dirlookup+0x29>
    }
  }

  return 0;
8010229b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022a0:	c9                   	leave
801022a1:	c3                   	ret

801022a2 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801022a2:	55                   	push   %ebp
801022a3:	89 e5                	mov    %esp,%ebp
801022a5:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801022a8:	83 ec 04             	sub    $0x4,%esp
801022ab:	6a 00                	push   $0x0
801022ad:	ff 75 0c             	push   0xc(%ebp)
801022b0:	ff 75 08             	push   0x8(%ebp)
801022b3:	e8 30 ff ff ff       	call   801021e8 <dirlookup>
801022b8:	83 c4 10             	add    $0x10,%esp
801022bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022c2:	74 18                	je     801022dc <dirlink+0x3a>
    iput(ip);
801022c4:	83 ec 0c             	sub    $0xc,%esp
801022c7:	ff 75 f0             	push   -0x10(%ebp)
801022ca:	e8 8a f8 ff ff       	call   80101b59 <iput>
801022cf:	83 c4 10             	add    $0x10,%esp
    return -1;
801022d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022d7:	e9 9c 00 00 00       	jmp    80102378 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022e3:	eb 39                	jmp    8010231e <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022e8:	6a 10                	push   $0x10
801022ea:	50                   	push   %eax
801022eb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022ee:	50                   	push   %eax
801022ef:	ff 75 08             	push   0x8(%ebp)
801022f2:	e8 fb fb ff ff       	call   80101ef2 <readi>
801022f7:	83 c4 10             	add    $0x10,%esp
801022fa:	83 f8 10             	cmp    $0x10,%eax
801022fd:	74 0d                	je     8010230c <dirlink+0x6a>
      panic("dirlink read");
801022ff:	83 ec 0c             	sub    $0xc,%esp
80102302:	68 1d 87 10 80       	push   $0x8010871d
80102307:	e8 6d e2 ff ff       	call   80100579 <panic>
    if(de.inum == 0)
8010230c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102310:	66 85 c0             	test   %ax,%ax
80102313:	74 18                	je     8010232d <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102315:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102318:	83 c0 10             	add    $0x10,%eax
8010231b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010231e:	8b 45 08             	mov    0x8(%ebp),%eax
80102321:	8b 40 18             	mov    0x18(%eax),%eax
80102324:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102327:	39 c2                	cmp    %eax,%edx
80102329:	72 ba                	jb     801022e5 <dirlink+0x43>
8010232b:	eb 01                	jmp    8010232e <dirlink+0x8c>
      break;
8010232d:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010232e:	83 ec 04             	sub    $0x4,%esp
80102331:	6a 0e                	push   $0xe
80102333:	ff 75 0c             	push   0xc(%ebp)
80102336:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102339:	83 c0 02             	add    $0x2,%eax
8010233c:	50                   	push   %eax
8010233d:	e8 2f 31 00 00       	call   80105471 <strncpy>
80102342:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102345:	8b 45 10             	mov    0x10(%ebp),%eax
80102348:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010234c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010234f:	6a 10                	push   $0x10
80102351:	50                   	push   %eax
80102352:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102355:	50                   	push   %eax
80102356:	ff 75 08             	push   0x8(%ebp)
80102359:	e8 e9 fc ff ff       	call   80102047 <writei>
8010235e:	83 c4 10             	add    $0x10,%esp
80102361:	83 f8 10             	cmp    $0x10,%eax
80102364:	74 0d                	je     80102373 <dirlink+0xd1>
    panic("dirlink");
80102366:	83 ec 0c             	sub    $0xc,%esp
80102369:	68 2a 87 10 80       	push   $0x8010872a
8010236e:	e8 06 e2 ff ff       	call   80100579 <panic>
  
  return 0;
80102373:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102378:	c9                   	leave
80102379:	c3                   	ret

8010237a <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010237a:	55                   	push   %ebp
8010237b:	89 e5                	mov    %esp,%ebp
8010237d:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102380:	eb 04                	jmp    80102386 <skipelem+0xc>
    path++;
80102382:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102386:	8b 45 08             	mov    0x8(%ebp),%eax
80102389:	0f b6 00             	movzbl (%eax),%eax
8010238c:	3c 2f                	cmp    $0x2f,%al
8010238e:	74 f2                	je     80102382 <skipelem+0x8>
  if(*path == 0)
80102390:	8b 45 08             	mov    0x8(%ebp),%eax
80102393:	0f b6 00             	movzbl (%eax),%eax
80102396:	84 c0                	test   %al,%al
80102398:	75 07                	jne    801023a1 <skipelem+0x27>
    return 0;
8010239a:	b8 00 00 00 00       	mov    $0x0,%eax
8010239f:	eb 77                	jmp    80102418 <skipelem+0x9e>
  s = path;
801023a1:	8b 45 08             	mov    0x8(%ebp),%eax
801023a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801023a7:	eb 04                	jmp    801023ad <skipelem+0x33>
    path++;
801023a9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
801023ad:	8b 45 08             	mov    0x8(%ebp),%eax
801023b0:	0f b6 00             	movzbl (%eax),%eax
801023b3:	3c 2f                	cmp    $0x2f,%al
801023b5:	74 0a                	je     801023c1 <skipelem+0x47>
801023b7:	8b 45 08             	mov    0x8(%ebp),%eax
801023ba:	0f b6 00             	movzbl (%eax),%eax
801023bd:	84 c0                	test   %al,%al
801023bf:	75 e8                	jne    801023a9 <skipelem+0x2f>
  len = path - s;
801023c1:	8b 45 08             	mov    0x8(%ebp),%eax
801023c4:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023ca:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023ce:	7e 15                	jle    801023e5 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023d0:	83 ec 04             	sub    $0x4,%esp
801023d3:	6a 0e                	push   $0xe
801023d5:	ff 75 f4             	push   -0xc(%ebp)
801023d8:	ff 75 0c             	push   0xc(%ebp)
801023db:	e8 a5 2f 00 00       	call   80105385 <memmove>
801023e0:	83 c4 10             	add    $0x10,%esp
801023e3:	eb 26                	jmp    8010240b <skipelem+0x91>
  else {
    memmove(name, s, len);
801023e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023e8:	83 ec 04             	sub    $0x4,%esp
801023eb:	50                   	push   %eax
801023ec:	ff 75 f4             	push   -0xc(%ebp)
801023ef:	ff 75 0c             	push   0xc(%ebp)
801023f2:	e8 8e 2f 00 00       	call   80105385 <memmove>
801023f7:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80102400:	01 d0                	add    %edx,%eax
80102402:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102405:	eb 04                	jmp    8010240b <skipelem+0x91>
    path++;
80102407:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010240b:	8b 45 08             	mov    0x8(%ebp),%eax
8010240e:	0f b6 00             	movzbl (%eax),%eax
80102411:	3c 2f                	cmp    $0x2f,%al
80102413:	74 f2                	je     80102407 <skipelem+0x8d>
  return path;
80102415:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102418:	c9                   	leave
80102419:	c3                   	ret

8010241a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010241a:	55                   	push   %ebp
8010241b:	89 e5                	mov    %esp,%ebp
8010241d:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102420:	8b 45 08             	mov    0x8(%ebp),%eax
80102423:	0f b6 00             	movzbl (%eax),%eax
80102426:	3c 2f                	cmp    $0x2f,%al
80102428:	75 17                	jne    80102441 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010242a:	83 ec 08             	sub    $0x8,%esp
8010242d:	6a 01                	push   $0x1
8010242f:	6a 01                	push   $0x1
80102431:	e8 3a f4 ff ff       	call   80101870 <iget>
80102436:	83 c4 10             	add    $0x10,%esp
80102439:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010243c:	e9 bb 00 00 00       	jmp    801024fc <namex+0xe2>
  else
    ip = idup(proc->cwd);
80102441:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102447:	8b 40 68             	mov    0x68(%eax),%eax
8010244a:	83 ec 0c             	sub    $0xc,%esp
8010244d:	50                   	push   %eax
8010244e:	e8 fc f4 ff ff       	call   8010194f <idup>
80102453:	83 c4 10             	add    $0x10,%esp
80102456:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102459:	e9 9e 00 00 00       	jmp    801024fc <namex+0xe2>
    ilock(ip);
8010245e:	83 ec 0c             	sub    $0xc,%esp
80102461:	ff 75 f4             	push   -0xc(%ebp)
80102464:	e8 20 f5 ff ff       	call   80101989 <ilock>
80102469:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010246c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010246f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102473:	66 83 f8 01          	cmp    $0x1,%ax
80102477:	74 18                	je     80102491 <namex+0x77>
      iunlockput(ip);
80102479:	83 ec 0c             	sub    $0xc,%esp
8010247c:	ff 75 f4             	push   -0xc(%ebp)
8010247f:	e8 c5 f7 ff ff       	call   80101c49 <iunlockput>
80102484:	83 c4 10             	add    $0x10,%esp
      return 0;
80102487:	b8 00 00 00 00       	mov    $0x0,%eax
8010248c:	e9 a7 00 00 00       	jmp    80102538 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
80102491:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102495:	74 20                	je     801024b7 <namex+0x9d>
80102497:	8b 45 08             	mov    0x8(%ebp),%eax
8010249a:	0f b6 00             	movzbl (%eax),%eax
8010249d:	84 c0                	test   %al,%al
8010249f:	75 16                	jne    801024b7 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
801024a1:	83 ec 0c             	sub    $0xc,%esp
801024a4:	ff 75 f4             	push   -0xc(%ebp)
801024a7:	e8 3b f6 ff ff       	call   80101ae7 <iunlock>
801024ac:	83 c4 10             	add    $0x10,%esp
      return ip;
801024af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024b2:	e9 81 00 00 00       	jmp    80102538 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024b7:	83 ec 04             	sub    $0x4,%esp
801024ba:	6a 00                	push   $0x0
801024bc:	ff 75 10             	push   0x10(%ebp)
801024bf:	ff 75 f4             	push   -0xc(%ebp)
801024c2:	e8 21 fd ff ff       	call   801021e8 <dirlookup>
801024c7:	83 c4 10             	add    $0x10,%esp
801024ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024d1:	75 15                	jne    801024e8 <namex+0xce>
      iunlockput(ip);
801024d3:	83 ec 0c             	sub    $0xc,%esp
801024d6:	ff 75 f4             	push   -0xc(%ebp)
801024d9:	e8 6b f7 ff ff       	call   80101c49 <iunlockput>
801024de:	83 c4 10             	add    $0x10,%esp
      return 0;
801024e1:	b8 00 00 00 00       	mov    $0x0,%eax
801024e6:	eb 50                	jmp    80102538 <namex+0x11e>
    }
    iunlockput(ip);
801024e8:	83 ec 0c             	sub    $0xc,%esp
801024eb:	ff 75 f4             	push   -0xc(%ebp)
801024ee:	e8 56 f7 ff ff       	call   80101c49 <iunlockput>
801024f3:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024fc:	83 ec 08             	sub    $0x8,%esp
801024ff:	ff 75 10             	push   0x10(%ebp)
80102502:	ff 75 08             	push   0x8(%ebp)
80102505:	e8 70 fe ff ff       	call   8010237a <skipelem>
8010250a:	83 c4 10             	add    $0x10,%esp
8010250d:	89 45 08             	mov    %eax,0x8(%ebp)
80102510:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102514:	0f 85 44 ff ff ff    	jne    8010245e <namex+0x44>
  }
  if(nameiparent){
8010251a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010251e:	74 15                	je     80102535 <namex+0x11b>
    iput(ip);
80102520:	83 ec 0c             	sub    $0xc,%esp
80102523:	ff 75 f4             	push   -0xc(%ebp)
80102526:	e8 2e f6 ff ff       	call   80101b59 <iput>
8010252b:	83 c4 10             	add    $0x10,%esp
    return 0;
8010252e:	b8 00 00 00 00       	mov    $0x0,%eax
80102533:	eb 03                	jmp    80102538 <namex+0x11e>
  }
  return ip;
80102535:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102538:	c9                   	leave
80102539:	c3                   	ret

8010253a <namei>:

struct inode*
namei(char *path)
{
8010253a:	55                   	push   %ebp
8010253b:	89 e5                	mov    %esp,%ebp
8010253d:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102540:	83 ec 04             	sub    $0x4,%esp
80102543:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102546:	50                   	push   %eax
80102547:	6a 00                	push   $0x0
80102549:	ff 75 08             	push   0x8(%ebp)
8010254c:	e8 c9 fe ff ff       	call   8010241a <namex>
80102551:	83 c4 10             	add    $0x10,%esp
}
80102554:	c9                   	leave
80102555:	c3                   	ret

80102556 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102556:	55                   	push   %ebp
80102557:	89 e5                	mov    %esp,%ebp
80102559:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010255c:	83 ec 04             	sub    $0x4,%esp
8010255f:	ff 75 0c             	push   0xc(%ebp)
80102562:	6a 01                	push   $0x1
80102564:	ff 75 08             	push   0x8(%ebp)
80102567:	e8 ae fe ff ff       	call   8010241a <namex>
8010256c:	83 c4 10             	add    $0x10,%esp
}
8010256f:	c9                   	leave
80102570:	c3                   	ret

80102571 <inb>:
{
80102571:	55                   	push   %ebp
80102572:	89 e5                	mov    %esp,%ebp
80102574:	83 ec 14             	sub    $0x14,%esp
80102577:	8b 45 08             	mov    0x8(%ebp),%eax
8010257a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010257e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102582:	89 c2                	mov    %eax,%edx
80102584:	ec                   	in     (%dx),%al
80102585:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102588:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010258c:	c9                   	leave
8010258d:	c3                   	ret

8010258e <insl>:
{
8010258e:	55                   	push   %ebp
8010258f:	89 e5                	mov    %esp,%ebp
80102591:	57                   	push   %edi
80102592:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102593:	8b 55 08             	mov    0x8(%ebp),%edx
80102596:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102599:	8b 45 10             	mov    0x10(%ebp),%eax
8010259c:	89 cb                	mov    %ecx,%ebx
8010259e:	89 df                	mov    %ebx,%edi
801025a0:	89 c1                	mov    %eax,%ecx
801025a2:	fc                   	cld
801025a3:	f3 6d                	rep insl (%dx),%es:(%edi)
801025a5:	89 c8                	mov    %ecx,%eax
801025a7:	89 fb                	mov    %edi,%ebx
801025a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025ac:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025af:	90                   	nop
801025b0:	5b                   	pop    %ebx
801025b1:	5f                   	pop    %edi
801025b2:	5d                   	pop    %ebp
801025b3:	c3                   	ret

801025b4 <outb>:
{
801025b4:	55                   	push   %ebp
801025b5:	89 e5                	mov    %esp,%ebp
801025b7:	83 ec 08             	sub    $0x8,%esp
801025ba:	8b 55 08             	mov    0x8(%ebp),%edx
801025bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801025c0:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801025c4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025c7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025cb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025cf:	ee                   	out    %al,(%dx)
}
801025d0:	90                   	nop
801025d1:	c9                   	leave
801025d2:	c3                   	ret

801025d3 <outsl>:
{
801025d3:	55                   	push   %ebp
801025d4:	89 e5                	mov    %esp,%ebp
801025d6:	56                   	push   %esi
801025d7:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025d8:	8b 55 08             	mov    0x8(%ebp),%edx
801025db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025de:	8b 45 10             	mov    0x10(%ebp),%eax
801025e1:	89 cb                	mov    %ecx,%ebx
801025e3:	89 de                	mov    %ebx,%esi
801025e5:	89 c1                	mov    %eax,%ecx
801025e7:	fc                   	cld
801025e8:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025ea:	89 c8                	mov    %ecx,%eax
801025ec:	89 f3                	mov    %esi,%ebx
801025ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025f1:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025f4:	90                   	nop
801025f5:	5b                   	pop    %ebx
801025f6:	5e                   	pop    %esi
801025f7:	5d                   	pop    %ebp
801025f8:	c3                   	ret

801025f9 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025f9:	55                   	push   %ebp
801025fa:	89 e5                	mov    %esp,%ebp
801025fc:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801025ff:	90                   	nop
80102600:	68 f7 01 00 00       	push   $0x1f7
80102605:	e8 67 ff ff ff       	call   80102571 <inb>
8010260a:	83 c4 04             	add    $0x4,%esp
8010260d:	0f b6 c0             	movzbl %al,%eax
80102610:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102613:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102616:	25 c0 00 00 00       	and    $0xc0,%eax
8010261b:	83 f8 40             	cmp    $0x40,%eax
8010261e:	75 e0                	jne    80102600 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102620:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102624:	74 11                	je     80102637 <idewait+0x3e>
80102626:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102629:	83 e0 21             	and    $0x21,%eax
8010262c:	85 c0                	test   %eax,%eax
8010262e:	74 07                	je     80102637 <idewait+0x3e>
    return -1;
80102630:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102635:	eb 05                	jmp    8010263c <idewait+0x43>
  return 0;
80102637:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010263c:	c9                   	leave
8010263d:	c3                   	ret

8010263e <ideinit>:

void
ideinit(void)
{
8010263e:	55                   	push   %ebp
8010263f:	89 e5                	mov    %esp,%ebp
80102641:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102644:	83 ec 08             	sub    $0x8,%esp
80102647:	68 32 87 10 80       	push   $0x80108732
8010264c:	68 a0 11 11 80       	push   $0x801111a0
80102651:	e8 ea 29 00 00       	call   80105040 <initlock>
80102656:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102659:	83 ec 0c             	sub    $0xc,%esp
8010265c:	6a 0e                	push   $0xe
8010265e:	e8 08 19 00 00       	call   80103f6b <picenable>
80102663:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102666:	a1 04 19 11 80       	mov    0x80111904,%eax
8010266b:	83 e8 01             	sub    $0x1,%eax
8010266e:	83 ec 08             	sub    $0x8,%esp
80102671:	50                   	push   %eax
80102672:	6a 0e                	push   $0xe
80102674:	e8 73 04 00 00       	call   80102aec <ioapicenable>
80102679:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010267c:	83 ec 0c             	sub    $0xc,%esp
8010267f:	6a 00                	push   $0x0
80102681:	e8 73 ff ff ff       	call   801025f9 <idewait>
80102686:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102689:	83 ec 08             	sub    $0x8,%esp
8010268c:	68 f0 00 00 00       	push   $0xf0
80102691:	68 f6 01 00 00       	push   $0x1f6
80102696:	e8 19 ff ff ff       	call   801025b4 <outb>
8010269b:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010269e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026a5:	eb 24                	jmp    801026cb <ideinit+0x8d>
    if(inb(0x1f7) != 0){
801026a7:	83 ec 0c             	sub    $0xc,%esp
801026aa:	68 f7 01 00 00       	push   $0x1f7
801026af:	e8 bd fe ff ff       	call   80102571 <inb>
801026b4:	83 c4 10             	add    $0x10,%esp
801026b7:	84 c0                	test   %al,%al
801026b9:	74 0c                	je     801026c7 <ideinit+0x89>
      havedisk1 = 1;
801026bb:	c7 05 d8 11 11 80 01 	movl   $0x1,0x801111d8
801026c2:	00 00 00 
      break;
801026c5:	eb 0d                	jmp    801026d4 <ideinit+0x96>
  for(i=0; i<1000; i++){
801026c7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026cb:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026d2:	7e d3                	jle    801026a7 <ideinit+0x69>
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026d4:	83 ec 08             	sub    $0x8,%esp
801026d7:	68 e0 00 00 00       	push   $0xe0
801026dc:	68 f6 01 00 00       	push   $0x1f6
801026e1:	e8 ce fe ff ff       	call   801025b4 <outb>
801026e6:	83 c4 10             	add    $0x10,%esp
}
801026e9:	90                   	nop
801026ea:	c9                   	leave
801026eb:	c3                   	ret

801026ec <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026ec:	55                   	push   %ebp
801026ed:	89 e5                	mov    %esp,%ebp
801026ef:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026f2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026f6:	75 0d                	jne    80102705 <idestart+0x19>
    panic("idestart");
801026f8:	83 ec 0c             	sub    $0xc,%esp
801026fb:	68 36 87 10 80       	push   $0x80108736
80102700:	e8 74 de ff ff       	call   80100579 <panic>
  if(b->blockno >= FSSIZE)
80102705:	8b 45 08             	mov    0x8(%ebp),%eax
80102708:	8b 40 08             	mov    0x8(%eax),%eax
8010270b:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102710:	76 0d                	jbe    8010271f <idestart+0x33>
    panic("incorrect blockno");
80102712:	83 ec 0c             	sub    $0xc,%esp
80102715:	68 3f 87 10 80       	push   $0x8010873f
8010271a:	e8 5a de ff ff       	call   80100579 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010271f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102726:	8b 45 08             	mov    0x8(%ebp),%eax
80102729:	8b 50 08             	mov    0x8(%eax),%edx
8010272c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010272f:	0f af c2             	imul   %edx,%eax
80102732:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102735:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102739:	7e 0d                	jle    80102748 <idestart+0x5c>
8010273b:	83 ec 0c             	sub    $0xc,%esp
8010273e:	68 36 87 10 80       	push   $0x80108736
80102743:	e8 31 de ff ff       	call   80100579 <panic>
  
  idewait(0);
80102748:	83 ec 0c             	sub    $0xc,%esp
8010274b:	6a 00                	push   $0x0
8010274d:	e8 a7 fe ff ff       	call   801025f9 <idewait>
80102752:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102755:	83 ec 08             	sub    $0x8,%esp
80102758:	6a 00                	push   $0x0
8010275a:	68 f6 03 00 00       	push   $0x3f6
8010275f:	e8 50 fe ff ff       	call   801025b4 <outb>
80102764:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010276a:	0f b6 c0             	movzbl %al,%eax
8010276d:	83 ec 08             	sub    $0x8,%esp
80102770:	50                   	push   %eax
80102771:	68 f2 01 00 00       	push   $0x1f2
80102776:	e8 39 fe ff ff       	call   801025b4 <outb>
8010277b:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010277e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102781:	0f b6 c0             	movzbl %al,%eax
80102784:	83 ec 08             	sub    $0x8,%esp
80102787:	50                   	push   %eax
80102788:	68 f3 01 00 00       	push   $0x1f3
8010278d:	e8 22 fe ff ff       	call   801025b4 <outb>
80102792:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102795:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102798:	c1 f8 08             	sar    $0x8,%eax
8010279b:	0f b6 c0             	movzbl %al,%eax
8010279e:	83 ec 08             	sub    $0x8,%esp
801027a1:	50                   	push   %eax
801027a2:	68 f4 01 00 00       	push   $0x1f4
801027a7:	e8 08 fe ff ff       	call   801025b4 <outb>
801027ac:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801027af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027b2:	c1 f8 10             	sar    $0x10,%eax
801027b5:	0f b6 c0             	movzbl %al,%eax
801027b8:	83 ec 08             	sub    $0x8,%esp
801027bb:	50                   	push   %eax
801027bc:	68 f5 01 00 00       	push   $0x1f5
801027c1:	e8 ee fd ff ff       	call   801025b4 <outb>
801027c6:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027c9:	8b 45 08             	mov    0x8(%ebp),%eax
801027cc:	8b 40 04             	mov    0x4(%eax),%eax
801027cf:	c1 e0 04             	shl    $0x4,%eax
801027d2:	83 e0 10             	and    $0x10,%eax
801027d5:	89 c2                	mov    %eax,%edx
801027d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027da:	c1 f8 18             	sar    $0x18,%eax
801027dd:	83 e0 0f             	and    $0xf,%eax
801027e0:	09 d0                	or     %edx,%eax
801027e2:	83 c8 e0             	or     $0xffffffe0,%eax
801027e5:	0f b6 c0             	movzbl %al,%eax
801027e8:	83 ec 08             	sub    $0x8,%esp
801027eb:	50                   	push   %eax
801027ec:	68 f6 01 00 00       	push   $0x1f6
801027f1:	e8 be fd ff ff       	call   801025b4 <outb>
801027f6:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801027f9:	8b 45 08             	mov    0x8(%ebp),%eax
801027fc:	8b 00                	mov    (%eax),%eax
801027fe:	83 e0 04             	and    $0x4,%eax
80102801:	85 c0                	test   %eax,%eax
80102803:	74 30                	je     80102835 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
80102805:	83 ec 08             	sub    $0x8,%esp
80102808:	6a 30                	push   $0x30
8010280a:	68 f7 01 00 00       	push   $0x1f7
8010280f:	e8 a0 fd ff ff       	call   801025b4 <outb>
80102814:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102817:	8b 45 08             	mov    0x8(%ebp),%eax
8010281a:	83 c0 18             	add    $0x18,%eax
8010281d:	83 ec 04             	sub    $0x4,%esp
80102820:	68 80 00 00 00       	push   $0x80
80102825:	50                   	push   %eax
80102826:	68 f0 01 00 00       	push   $0x1f0
8010282b:	e8 a3 fd ff ff       	call   801025d3 <outsl>
80102830:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102833:	eb 12                	jmp    80102847 <idestart+0x15b>
    outb(0x1f7, IDE_CMD_READ);
80102835:	83 ec 08             	sub    $0x8,%esp
80102838:	6a 20                	push   $0x20
8010283a:	68 f7 01 00 00       	push   $0x1f7
8010283f:	e8 70 fd ff ff       	call   801025b4 <outb>
80102844:	83 c4 10             	add    $0x10,%esp
}
80102847:	90                   	nop
80102848:	c9                   	leave
80102849:	c3                   	ret

8010284a <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010284a:	55                   	push   %ebp
8010284b:	89 e5                	mov    %esp,%ebp
8010284d:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102850:	83 ec 0c             	sub    $0xc,%esp
80102853:	68 a0 11 11 80       	push   $0x801111a0
80102858:	e8 05 28 00 00       	call   80105062 <acquire>
8010285d:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102860:	a1 d4 11 11 80       	mov    0x801111d4,%eax
80102865:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102868:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010286c:	75 15                	jne    80102883 <ideintr+0x39>
    release(&idelock);
8010286e:	83 ec 0c             	sub    $0xc,%esp
80102871:	68 a0 11 11 80       	push   $0x801111a0
80102876:	e8 4e 28 00 00       	call   801050c9 <release>
8010287b:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
8010287e:	e9 9a 00 00 00       	jmp    8010291d <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102886:	8b 40 14             	mov    0x14(%eax),%eax
80102889:	a3 d4 11 11 80       	mov    %eax,0x801111d4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010288e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102891:	8b 00                	mov    (%eax),%eax
80102893:	83 e0 04             	and    $0x4,%eax
80102896:	85 c0                	test   %eax,%eax
80102898:	75 2d                	jne    801028c7 <ideintr+0x7d>
8010289a:	83 ec 0c             	sub    $0xc,%esp
8010289d:	6a 01                	push   $0x1
8010289f:	e8 55 fd ff ff       	call   801025f9 <idewait>
801028a4:	83 c4 10             	add    $0x10,%esp
801028a7:	85 c0                	test   %eax,%eax
801028a9:	78 1c                	js     801028c7 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801028ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ae:	83 c0 18             	add    $0x18,%eax
801028b1:	83 ec 04             	sub    $0x4,%esp
801028b4:	68 80 00 00 00       	push   $0x80
801028b9:	50                   	push   %eax
801028ba:	68 f0 01 00 00       	push   $0x1f0
801028bf:	e8 ca fc ff ff       	call   8010258e <insl>
801028c4:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ca:	8b 00                	mov    (%eax),%eax
801028cc:	83 c8 02             	or     $0x2,%eax
801028cf:	89 c2                	mov    %eax,%edx
801028d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d4:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d9:	8b 00                	mov    (%eax),%eax
801028db:	83 e0 fb             	and    $0xfffffffb,%eax
801028de:	89 c2                	mov    %eax,%edx
801028e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e3:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028e5:	83 ec 0c             	sub    $0xc,%esp
801028e8:	ff 75 f4             	push   -0xc(%ebp)
801028eb:	e8 63 25 00 00       	call   80104e53 <wakeup>
801028f0:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801028f3:	a1 d4 11 11 80       	mov    0x801111d4,%eax
801028f8:	85 c0                	test   %eax,%eax
801028fa:	74 11                	je     8010290d <ideintr+0xc3>
    idestart(idequeue);
801028fc:	a1 d4 11 11 80       	mov    0x801111d4,%eax
80102901:	83 ec 0c             	sub    $0xc,%esp
80102904:	50                   	push   %eax
80102905:	e8 e2 fd ff ff       	call   801026ec <idestart>
8010290a:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
8010290d:	83 ec 0c             	sub    $0xc,%esp
80102910:	68 a0 11 11 80       	push   $0x801111a0
80102915:	e8 af 27 00 00       	call   801050c9 <release>
8010291a:	83 c4 10             	add    $0x10,%esp
}
8010291d:	c9                   	leave
8010291e:	c3                   	ret

8010291f <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010291f:	55                   	push   %ebp
80102920:	89 e5                	mov    %esp,%ebp
80102922:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102925:	8b 45 08             	mov    0x8(%ebp),%eax
80102928:	8b 00                	mov    (%eax),%eax
8010292a:	83 e0 01             	and    $0x1,%eax
8010292d:	85 c0                	test   %eax,%eax
8010292f:	75 0d                	jne    8010293e <iderw+0x1f>
    panic("iderw: buf not busy");
80102931:	83 ec 0c             	sub    $0xc,%esp
80102934:	68 51 87 10 80       	push   $0x80108751
80102939:	e8 3b dc ff ff       	call   80100579 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010293e:	8b 45 08             	mov    0x8(%ebp),%eax
80102941:	8b 00                	mov    (%eax),%eax
80102943:	83 e0 06             	and    $0x6,%eax
80102946:	83 f8 02             	cmp    $0x2,%eax
80102949:	75 0d                	jne    80102958 <iderw+0x39>
    panic("iderw: nothing to do");
8010294b:	83 ec 0c             	sub    $0xc,%esp
8010294e:	68 65 87 10 80       	push   $0x80108765
80102953:	e8 21 dc ff ff       	call   80100579 <panic>
  if(b->dev != 0 && !havedisk1)
80102958:	8b 45 08             	mov    0x8(%ebp),%eax
8010295b:	8b 40 04             	mov    0x4(%eax),%eax
8010295e:	85 c0                	test   %eax,%eax
80102960:	74 16                	je     80102978 <iderw+0x59>
80102962:	a1 d8 11 11 80       	mov    0x801111d8,%eax
80102967:	85 c0                	test   %eax,%eax
80102969:	75 0d                	jne    80102978 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
8010296b:	83 ec 0c             	sub    $0xc,%esp
8010296e:	68 7a 87 10 80       	push   $0x8010877a
80102973:	e8 01 dc ff ff       	call   80100579 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102978:	83 ec 0c             	sub    $0xc,%esp
8010297b:	68 a0 11 11 80       	push   $0x801111a0
80102980:	e8 dd 26 00 00       	call   80105062 <acquire>
80102985:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102988:	8b 45 08             	mov    0x8(%ebp),%eax
8010298b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102992:	c7 45 f4 d4 11 11 80 	movl   $0x801111d4,-0xc(%ebp)
80102999:	eb 0b                	jmp    801029a6 <iderw+0x87>
8010299b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010299e:	8b 00                	mov    (%eax),%eax
801029a0:	83 c0 14             	add    $0x14,%eax
801029a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a9:	8b 00                	mov    (%eax),%eax
801029ab:	85 c0                	test   %eax,%eax
801029ad:	75 ec                	jne    8010299b <iderw+0x7c>
    ;
  *pp = b;
801029af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b2:	8b 55 08             	mov    0x8(%ebp),%edx
801029b5:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801029b7:	a1 d4 11 11 80       	mov    0x801111d4,%eax
801029bc:	39 45 08             	cmp    %eax,0x8(%ebp)
801029bf:	75 23                	jne    801029e4 <iderw+0xc5>
    idestart(b);
801029c1:	83 ec 0c             	sub    $0xc,%esp
801029c4:	ff 75 08             	push   0x8(%ebp)
801029c7:	e8 20 fd ff ff       	call   801026ec <idestart>
801029cc:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029cf:	eb 13                	jmp    801029e4 <iderw+0xc5>
    sleep(b, &idelock);
801029d1:	83 ec 08             	sub    $0x8,%esp
801029d4:	68 a0 11 11 80       	push   $0x801111a0
801029d9:	ff 75 08             	push   0x8(%ebp)
801029dc:	e8 86 23 00 00       	call   80104d67 <sleep>
801029e1:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029e4:	8b 45 08             	mov    0x8(%ebp),%eax
801029e7:	8b 00                	mov    (%eax),%eax
801029e9:	83 e0 06             	and    $0x6,%eax
801029ec:	83 f8 02             	cmp    $0x2,%eax
801029ef:	75 e0                	jne    801029d1 <iderw+0xb2>
  }

  release(&idelock);
801029f1:	83 ec 0c             	sub    $0xc,%esp
801029f4:	68 a0 11 11 80       	push   $0x801111a0
801029f9:	e8 cb 26 00 00       	call   801050c9 <release>
801029fe:	83 c4 10             	add    $0x10,%esp
}
80102a01:	90                   	nop
80102a02:	c9                   	leave
80102a03:	c3                   	ret

80102a04 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a04:	55                   	push   %ebp
80102a05:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a07:	a1 dc 11 11 80       	mov    0x801111dc,%eax
80102a0c:	8b 55 08             	mov    0x8(%ebp),%edx
80102a0f:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a11:	a1 dc 11 11 80       	mov    0x801111dc,%eax
80102a16:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a19:	5d                   	pop    %ebp
80102a1a:	c3                   	ret

80102a1b <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a1b:	55                   	push   %ebp
80102a1c:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a1e:	a1 dc 11 11 80       	mov    0x801111dc,%eax
80102a23:	8b 55 08             	mov    0x8(%ebp),%edx
80102a26:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a28:	a1 dc 11 11 80       	mov    0x801111dc,%eax
80102a2d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a30:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a33:	90                   	nop
80102a34:	5d                   	pop    %ebp
80102a35:	c3                   	ret

80102a36 <ioapicinit>:

void
ioapicinit(void)
{
80102a36:	55                   	push   %ebp
80102a37:	89 e5                	mov    %esp,%ebp
80102a39:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102a3c:	a1 00 19 11 80       	mov    0x80111900,%eax
80102a41:	85 c0                	test   %eax,%eax
80102a43:	0f 84 a0 00 00 00    	je     80102ae9 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a49:	c7 05 dc 11 11 80 00 	movl   $0xfec00000,0x801111dc
80102a50:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a53:	6a 01                	push   $0x1
80102a55:	e8 aa ff ff ff       	call   80102a04 <ioapicread>
80102a5a:	83 c4 04             	add    $0x4,%esp
80102a5d:	c1 e8 10             	shr    $0x10,%eax
80102a60:	25 ff 00 00 00       	and    $0xff,%eax
80102a65:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a68:	6a 00                	push   $0x0
80102a6a:	e8 95 ff ff ff       	call   80102a04 <ioapicread>
80102a6f:	83 c4 04             	add    $0x4,%esp
80102a72:	c1 e8 18             	shr    $0x18,%eax
80102a75:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a78:	0f b6 05 08 19 11 80 	movzbl 0x80111908,%eax
80102a7f:	0f b6 c0             	movzbl %al,%eax
80102a82:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102a85:	74 10                	je     80102a97 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a87:	83 ec 0c             	sub    $0xc,%esp
80102a8a:	68 98 87 10 80       	push   $0x80108798
80102a8f:	e8 30 d9 ff ff       	call   801003c4 <cprintf>
80102a94:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a9e:	eb 3f                	jmp    80102adf <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa3:	83 c0 20             	add    $0x20,%eax
80102aa6:	0d 00 00 01 00       	or     $0x10000,%eax
80102aab:	89 c2                	mov    %eax,%edx
80102aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab0:	83 c0 08             	add    $0x8,%eax
80102ab3:	01 c0                	add    %eax,%eax
80102ab5:	83 ec 08             	sub    $0x8,%esp
80102ab8:	52                   	push   %edx
80102ab9:	50                   	push   %eax
80102aba:	e8 5c ff ff ff       	call   80102a1b <ioapicwrite>
80102abf:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac5:	83 c0 08             	add    $0x8,%eax
80102ac8:	01 c0                	add    %eax,%eax
80102aca:	83 c0 01             	add    $0x1,%eax
80102acd:	83 ec 08             	sub    $0x8,%esp
80102ad0:	6a 00                	push   $0x0
80102ad2:	50                   	push   %eax
80102ad3:	e8 43 ff ff ff       	call   80102a1b <ioapicwrite>
80102ad8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102adb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ae5:	7e b9                	jle    80102aa0 <ioapicinit+0x6a>
80102ae7:	eb 01                	jmp    80102aea <ioapicinit+0xb4>
    return;
80102ae9:	90                   	nop
  }
}
80102aea:	c9                   	leave
80102aeb:	c3                   	ret

80102aec <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102aec:	55                   	push   %ebp
80102aed:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102aef:	a1 00 19 11 80       	mov    0x80111900,%eax
80102af4:	85 c0                	test   %eax,%eax
80102af6:	74 39                	je     80102b31 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102af8:	8b 45 08             	mov    0x8(%ebp),%eax
80102afb:	83 c0 20             	add    $0x20,%eax
80102afe:	89 c2                	mov    %eax,%edx
80102b00:	8b 45 08             	mov    0x8(%ebp),%eax
80102b03:	83 c0 08             	add    $0x8,%eax
80102b06:	01 c0                	add    %eax,%eax
80102b08:	52                   	push   %edx
80102b09:	50                   	push   %eax
80102b0a:	e8 0c ff ff ff       	call   80102a1b <ioapicwrite>
80102b0f:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b12:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b15:	c1 e0 18             	shl    $0x18,%eax
80102b18:	89 c2                	mov    %eax,%edx
80102b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1d:	83 c0 08             	add    $0x8,%eax
80102b20:	01 c0                	add    %eax,%eax
80102b22:	83 c0 01             	add    $0x1,%eax
80102b25:	52                   	push   %edx
80102b26:	50                   	push   %eax
80102b27:	e8 ef fe ff ff       	call   80102a1b <ioapicwrite>
80102b2c:	83 c4 08             	add    $0x8,%esp
80102b2f:	eb 01                	jmp    80102b32 <ioapicenable+0x46>
    return;
80102b31:	90                   	nop
}
80102b32:	c9                   	leave
80102b33:	c3                   	ret

80102b34 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102b34:	55                   	push   %ebp
80102b35:	89 e5                	mov    %esp,%ebp
80102b37:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3a:	05 00 00 00 80       	add    $0x80000000,%eax
80102b3f:	5d                   	pop    %ebp
80102b40:	c3                   	ret

80102b41 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b41:	55                   	push   %ebp
80102b42:	89 e5                	mov    %esp,%ebp
80102b44:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b47:	83 ec 08             	sub    $0x8,%esp
80102b4a:	68 ca 87 10 80       	push   $0x801087ca
80102b4f:	68 e0 11 11 80       	push   $0x801111e0
80102b54:	e8 e7 24 00 00       	call   80105040 <initlock>
80102b59:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b5c:	c7 05 14 12 11 80 00 	movl   $0x0,0x80111214
80102b63:	00 00 00 
  freerange(vstart, vend);
80102b66:	83 ec 08             	sub    $0x8,%esp
80102b69:	ff 75 0c             	push   0xc(%ebp)
80102b6c:	ff 75 08             	push   0x8(%ebp)
80102b6f:	e8 2a 00 00 00       	call   80102b9e <freerange>
80102b74:	83 c4 10             	add    $0x10,%esp
}
80102b77:	90                   	nop
80102b78:	c9                   	leave
80102b79:	c3                   	ret

80102b7a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b7a:	55                   	push   %ebp
80102b7b:	89 e5                	mov    %esp,%ebp
80102b7d:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b80:	83 ec 08             	sub    $0x8,%esp
80102b83:	ff 75 0c             	push   0xc(%ebp)
80102b86:	ff 75 08             	push   0x8(%ebp)
80102b89:	e8 10 00 00 00       	call   80102b9e <freerange>
80102b8e:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102b91:	c7 05 14 12 11 80 01 	movl   $0x1,0x80111214
80102b98:	00 00 00 
}
80102b9b:	90                   	nop
80102b9c:	c9                   	leave
80102b9d:	c3                   	ret

80102b9e <freerange>:

void
freerange(void *vstart, void *vend)
{
80102b9e:	55                   	push   %ebp
80102b9f:	89 e5                	mov    %esp,%ebp
80102ba1:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102ba4:	8b 45 08             	mov    0x8(%ebp),%eax
80102ba7:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bb4:	eb 15                	jmp    80102bcb <freerange+0x2d>
    kfree(p);
80102bb6:	83 ec 0c             	sub    $0xc,%esp
80102bb9:	ff 75 f4             	push   -0xc(%ebp)
80102bbc:	e8 1b 00 00 00       	call   80102bdc <kfree>
80102bc1:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bc4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bce:	05 00 10 00 00       	add    $0x1000,%eax
80102bd3:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102bd6:	73 de                	jae    80102bb6 <freerange+0x18>
}
80102bd8:	90                   	nop
80102bd9:	90                   	nop
80102bda:	c9                   	leave
80102bdb:	c3                   	ret

80102bdc <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bdc:	55                   	push   %ebp
80102bdd:	89 e5                	mov    %esp,%ebp
80102bdf:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102be2:	8b 45 08             	mov    0x8(%ebp),%eax
80102be5:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bea:	85 c0                	test   %eax,%eax
80102bec:	75 1b                	jne    80102c09 <kfree+0x2d>
80102bee:	81 7d 08 00 51 11 80 	cmpl   $0x80115100,0x8(%ebp)
80102bf5:	72 12                	jb     80102c09 <kfree+0x2d>
80102bf7:	ff 75 08             	push   0x8(%ebp)
80102bfa:	e8 35 ff ff ff       	call   80102b34 <v2p>
80102bff:	83 c4 04             	add    $0x4,%esp
80102c02:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c07:	76 0d                	jbe    80102c16 <kfree+0x3a>
    panic("kfree");
80102c09:	83 ec 0c             	sub    $0xc,%esp
80102c0c:	68 cf 87 10 80       	push   $0x801087cf
80102c11:	e8 63 d9 ff ff       	call   80100579 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c16:	83 ec 04             	sub    $0x4,%esp
80102c19:	68 00 10 00 00       	push   $0x1000
80102c1e:	6a 01                	push   $0x1
80102c20:	ff 75 08             	push   0x8(%ebp)
80102c23:	e8 9e 26 00 00       	call   801052c6 <memset>
80102c28:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c2b:	a1 14 12 11 80       	mov    0x80111214,%eax
80102c30:	85 c0                	test   %eax,%eax
80102c32:	74 10                	je     80102c44 <kfree+0x68>
    acquire(&kmem.lock);
80102c34:	83 ec 0c             	sub    $0xc,%esp
80102c37:	68 e0 11 11 80       	push   $0x801111e0
80102c3c:	e8 21 24 00 00       	call   80105062 <acquire>
80102c41:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c44:	8b 45 08             	mov    0x8(%ebp),%eax
80102c47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c4a:	8b 15 18 12 11 80    	mov    0x80111218,%edx
80102c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c53:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c58:	a3 18 12 11 80       	mov    %eax,0x80111218
  if(kmem.use_lock)
80102c5d:	a1 14 12 11 80       	mov    0x80111214,%eax
80102c62:	85 c0                	test   %eax,%eax
80102c64:	74 10                	je     80102c76 <kfree+0x9a>
    release(&kmem.lock);
80102c66:	83 ec 0c             	sub    $0xc,%esp
80102c69:	68 e0 11 11 80       	push   $0x801111e0
80102c6e:	e8 56 24 00 00       	call   801050c9 <release>
80102c73:	83 c4 10             	add    $0x10,%esp
}
80102c76:	90                   	nop
80102c77:	c9                   	leave
80102c78:	c3                   	ret

80102c79 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c79:	55                   	push   %ebp
80102c7a:	89 e5                	mov    %esp,%ebp
80102c7c:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c7f:	a1 14 12 11 80       	mov    0x80111214,%eax
80102c84:	85 c0                	test   %eax,%eax
80102c86:	74 10                	je     80102c98 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c88:	83 ec 0c             	sub    $0xc,%esp
80102c8b:	68 e0 11 11 80       	push   $0x801111e0
80102c90:	e8 cd 23 00 00       	call   80105062 <acquire>
80102c95:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102c98:	a1 18 12 11 80       	mov    0x80111218,%eax
80102c9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102ca0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102ca4:	74 0a                	je     80102cb0 <kalloc+0x37>
    kmem.freelist = r->next;
80102ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ca9:	8b 00                	mov    (%eax),%eax
80102cab:	a3 18 12 11 80       	mov    %eax,0x80111218
  if(kmem.use_lock)
80102cb0:	a1 14 12 11 80       	mov    0x80111214,%eax
80102cb5:	85 c0                	test   %eax,%eax
80102cb7:	74 10                	je     80102cc9 <kalloc+0x50>
    release(&kmem.lock);
80102cb9:	83 ec 0c             	sub    $0xc,%esp
80102cbc:	68 e0 11 11 80       	push   $0x801111e0
80102cc1:	e8 03 24 00 00       	call   801050c9 <release>
80102cc6:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102ccc:	c9                   	leave
80102ccd:	c3                   	ret

80102cce <inb>:
{
80102cce:	55                   	push   %ebp
80102ccf:	89 e5                	mov    %esp,%ebp
80102cd1:	83 ec 14             	sub    $0x14,%esp
80102cd4:	8b 45 08             	mov    0x8(%ebp),%eax
80102cd7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cdb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cdf:	89 c2                	mov    %eax,%edx
80102ce1:	ec                   	in     (%dx),%al
80102ce2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102ce5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102ce9:	c9                   	leave
80102cea:	c3                   	ret

80102ceb <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102ceb:	55                   	push   %ebp
80102cec:	89 e5                	mov    %esp,%ebp
80102cee:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102cf1:	6a 64                	push   $0x64
80102cf3:	e8 d6 ff ff ff       	call   80102cce <inb>
80102cf8:	83 c4 04             	add    $0x4,%esp
80102cfb:	0f b6 c0             	movzbl %al,%eax
80102cfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d04:	83 e0 01             	and    $0x1,%eax
80102d07:	85 c0                	test   %eax,%eax
80102d09:	75 0a                	jne    80102d15 <kbdgetc+0x2a>
    return -1;
80102d0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d10:	e9 23 01 00 00       	jmp    80102e38 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d15:	6a 60                	push   $0x60
80102d17:	e8 b2 ff ff ff       	call   80102cce <inb>
80102d1c:	83 c4 04             	add    $0x4,%esp
80102d1f:	0f b6 c0             	movzbl %al,%eax
80102d22:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d25:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d2c:	75 17                	jne    80102d45 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d2e:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102d33:	83 c8 40             	or     $0x40,%eax
80102d36:	a3 1c 12 11 80       	mov    %eax,0x8011121c
    return 0;
80102d3b:	b8 00 00 00 00       	mov    $0x0,%eax
80102d40:	e9 f3 00 00 00       	jmp    80102e38 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d45:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d48:	25 80 00 00 00       	and    $0x80,%eax
80102d4d:	85 c0                	test   %eax,%eax
80102d4f:	74 45                	je     80102d96 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d51:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102d56:	83 e0 40             	and    $0x40,%eax
80102d59:	85 c0                	test   %eax,%eax
80102d5b:	75 08                	jne    80102d65 <kbdgetc+0x7a>
80102d5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d60:	83 e0 7f             	and    $0x7f,%eax
80102d63:	eb 03                	jmp    80102d68 <kbdgetc+0x7d>
80102d65:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d68:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d6e:	05 20 90 10 80       	add    $0x80109020,%eax
80102d73:	0f b6 00             	movzbl (%eax),%eax
80102d76:	83 c8 40             	or     $0x40,%eax
80102d79:	0f b6 c0             	movzbl %al,%eax
80102d7c:	f7 d0                	not    %eax
80102d7e:	89 c2                	mov    %eax,%edx
80102d80:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102d85:	21 d0                	and    %edx,%eax
80102d87:	a3 1c 12 11 80       	mov    %eax,0x8011121c
    return 0;
80102d8c:	b8 00 00 00 00       	mov    $0x0,%eax
80102d91:	e9 a2 00 00 00       	jmp    80102e38 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102d96:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102d9b:	83 e0 40             	and    $0x40,%eax
80102d9e:	85 c0                	test   %eax,%eax
80102da0:	74 14                	je     80102db6 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102da2:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102da9:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102dae:	83 e0 bf             	and    $0xffffffbf,%eax
80102db1:	a3 1c 12 11 80       	mov    %eax,0x8011121c
  }

  shift |= shiftcode[data];
80102db6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102db9:	05 20 90 10 80       	add    $0x80109020,%eax
80102dbe:	0f b6 00             	movzbl (%eax),%eax
80102dc1:	0f b6 d0             	movzbl %al,%edx
80102dc4:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102dc9:	09 d0                	or     %edx,%eax
80102dcb:	a3 1c 12 11 80       	mov    %eax,0x8011121c
  shift ^= togglecode[data];
80102dd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dd3:	05 20 91 10 80       	add    $0x80109120,%eax
80102dd8:	0f b6 00             	movzbl (%eax),%eax
80102ddb:	0f b6 d0             	movzbl %al,%edx
80102dde:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102de3:	31 d0                	xor    %edx,%eax
80102de5:	a3 1c 12 11 80       	mov    %eax,0x8011121c
  c = charcode[shift & (CTL | SHIFT)][data];
80102dea:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102def:	83 e0 03             	and    $0x3,%eax
80102df2:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102df9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dfc:	01 d0                	add    %edx,%eax
80102dfe:	0f b6 00             	movzbl (%eax),%eax
80102e01:	0f b6 c0             	movzbl %al,%eax
80102e04:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e07:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102e0c:	83 e0 08             	and    $0x8,%eax
80102e0f:	85 c0                	test   %eax,%eax
80102e11:	74 22                	je     80102e35 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e13:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e17:	76 0c                	jbe    80102e25 <kbdgetc+0x13a>
80102e19:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e1d:	77 06                	ja     80102e25 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e1f:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e23:	eb 10                	jmp    80102e35 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e25:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e29:	76 0a                	jbe    80102e35 <kbdgetc+0x14a>
80102e2b:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e2f:	77 04                	ja     80102e35 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e31:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e35:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e38:	c9                   	leave
80102e39:	c3                   	ret

80102e3a <kbdintr>:

void
kbdintr(void)
{
80102e3a:	55                   	push   %ebp
80102e3b:	89 e5                	mov    %esp,%ebp
80102e3d:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e40:	83 ec 0c             	sub    $0xc,%esp
80102e43:	68 eb 2c 10 80       	push   $0x80102ceb
80102e48:	e8 c9 d9 ff ff       	call   80100816 <consoleintr>
80102e4d:	83 c4 10             	add    $0x10,%esp
}
80102e50:	90                   	nop
80102e51:	c9                   	leave
80102e52:	c3                   	ret

80102e53 <inb>:
{
80102e53:	55                   	push   %ebp
80102e54:	89 e5                	mov    %esp,%ebp
80102e56:	83 ec 14             	sub    $0x14,%esp
80102e59:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e60:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e64:	89 c2                	mov    %eax,%edx
80102e66:	ec                   	in     (%dx),%al
80102e67:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e6a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e6e:	c9                   	leave
80102e6f:	c3                   	ret

80102e70 <outb>:
{
80102e70:	55                   	push   %ebp
80102e71:	89 e5                	mov    %esp,%ebp
80102e73:	83 ec 08             	sub    $0x8,%esp
80102e76:	8b 55 08             	mov    0x8(%ebp),%edx
80102e79:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e7c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102e80:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e83:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e87:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e8b:	ee                   	out    %al,(%dx)
}
80102e8c:	90                   	nop
80102e8d:	c9                   	leave
80102e8e:	c3                   	ret

80102e8f <readeflags>:
{
80102e8f:	55                   	push   %ebp
80102e90:	89 e5                	mov    %esp,%ebp
80102e92:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102e95:	9c                   	pushf
80102e96:	58                   	pop    %eax
80102e97:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102e9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102e9d:	c9                   	leave
80102e9e:	c3                   	ret

80102e9f <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102e9f:	55                   	push   %ebp
80102ea0:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102ea2:	a1 20 12 11 80       	mov    0x80111220,%eax
80102ea7:	8b 55 08             	mov    0x8(%ebp),%edx
80102eaa:	c1 e2 02             	shl    $0x2,%edx
80102ead:	01 c2                	add    %eax,%edx
80102eaf:	8b 45 0c             	mov    0xc(%ebp),%eax
80102eb2:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102eb4:	a1 20 12 11 80       	mov    0x80111220,%eax
80102eb9:	83 c0 20             	add    $0x20,%eax
80102ebc:	8b 00                	mov    (%eax),%eax
}
80102ebe:	90                   	nop
80102ebf:	5d                   	pop    %ebp
80102ec0:	c3                   	ret

80102ec1 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102ec1:	55                   	push   %ebp
80102ec2:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102ec4:	a1 20 12 11 80       	mov    0x80111220,%eax
80102ec9:	85 c0                	test   %eax,%eax
80102ecb:	0f 84 09 01 00 00    	je     80102fda <lapicinit+0x119>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ed1:	68 3f 01 00 00       	push   $0x13f
80102ed6:	6a 3c                	push   $0x3c
80102ed8:	e8 c2 ff ff ff       	call   80102e9f <lapicw>
80102edd:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ee0:	6a 0b                	push   $0xb
80102ee2:	68 f8 00 00 00       	push   $0xf8
80102ee7:	e8 b3 ff ff ff       	call   80102e9f <lapicw>
80102eec:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102eef:	68 20 00 02 00       	push   $0x20020
80102ef4:	68 c8 00 00 00       	push   $0xc8
80102ef9:	e8 a1 ff ff ff       	call   80102e9f <lapicw>
80102efe:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102f01:	68 80 96 98 00       	push   $0x989680
80102f06:	68 e0 00 00 00       	push   $0xe0
80102f0b:	e8 8f ff ff ff       	call   80102e9f <lapicw>
80102f10:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f13:	68 00 00 01 00       	push   $0x10000
80102f18:	68 d4 00 00 00       	push   $0xd4
80102f1d:	e8 7d ff ff ff       	call   80102e9f <lapicw>
80102f22:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f25:	68 00 00 01 00       	push   $0x10000
80102f2a:	68 d8 00 00 00       	push   $0xd8
80102f2f:	e8 6b ff ff ff       	call   80102e9f <lapicw>
80102f34:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f37:	a1 20 12 11 80       	mov    0x80111220,%eax
80102f3c:	83 c0 30             	add    $0x30,%eax
80102f3f:	8b 00                	mov    (%eax),%eax
80102f41:	25 00 00 fc 00       	and    $0xfc0000,%eax
80102f46:	85 c0                	test   %eax,%eax
80102f48:	74 12                	je     80102f5c <lapicinit+0x9b>
    lapicw(PCINT, MASKED);
80102f4a:	68 00 00 01 00       	push   $0x10000
80102f4f:	68 d0 00 00 00       	push   $0xd0
80102f54:	e8 46 ff ff ff       	call   80102e9f <lapicw>
80102f59:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f5c:	6a 33                	push   $0x33
80102f5e:	68 dc 00 00 00       	push   $0xdc
80102f63:	e8 37 ff ff ff       	call   80102e9f <lapicw>
80102f68:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f6b:	6a 00                	push   $0x0
80102f6d:	68 a0 00 00 00       	push   $0xa0
80102f72:	e8 28 ff ff ff       	call   80102e9f <lapicw>
80102f77:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f7a:	6a 00                	push   $0x0
80102f7c:	68 a0 00 00 00       	push   $0xa0
80102f81:	e8 19 ff ff ff       	call   80102e9f <lapicw>
80102f86:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f89:	6a 00                	push   $0x0
80102f8b:	6a 2c                	push   $0x2c
80102f8d:	e8 0d ff ff ff       	call   80102e9f <lapicw>
80102f92:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f95:	6a 00                	push   $0x0
80102f97:	68 c4 00 00 00       	push   $0xc4
80102f9c:	e8 fe fe ff ff       	call   80102e9f <lapicw>
80102fa1:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fa4:	68 00 85 08 00       	push   $0x88500
80102fa9:	68 c0 00 00 00       	push   $0xc0
80102fae:	e8 ec fe ff ff       	call   80102e9f <lapicw>
80102fb3:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fb6:	90                   	nop
80102fb7:	a1 20 12 11 80       	mov    0x80111220,%eax
80102fbc:	05 00 03 00 00       	add    $0x300,%eax
80102fc1:	8b 00                	mov    (%eax),%eax
80102fc3:	25 00 10 00 00       	and    $0x1000,%eax
80102fc8:	85 c0                	test   %eax,%eax
80102fca:	75 eb                	jne    80102fb7 <lapicinit+0xf6>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fcc:	6a 00                	push   $0x0
80102fce:	6a 20                	push   $0x20
80102fd0:	e8 ca fe ff ff       	call   80102e9f <lapicw>
80102fd5:	83 c4 08             	add    $0x8,%esp
80102fd8:	eb 01                	jmp    80102fdb <lapicinit+0x11a>
    return;
80102fda:	90                   	nop
}
80102fdb:	c9                   	leave
80102fdc:	c3                   	ret

80102fdd <cpunum>:

int
cpunum(void)
{
80102fdd:	55                   	push   %ebp
80102fde:	89 e5                	mov    %esp,%ebp
80102fe0:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102fe3:	e8 a7 fe ff ff       	call   80102e8f <readeflags>
80102fe8:	25 00 02 00 00       	and    $0x200,%eax
80102fed:	85 c0                	test   %eax,%eax
80102fef:	74 26                	je     80103017 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80102ff1:	a1 24 12 11 80       	mov    0x80111224,%eax
80102ff6:	8d 50 01             	lea    0x1(%eax),%edx
80102ff9:	89 15 24 12 11 80    	mov    %edx,0x80111224
80102fff:	85 c0                	test   %eax,%eax
80103001:	75 14                	jne    80103017 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80103003:	8b 45 04             	mov    0x4(%ebp),%eax
80103006:	83 ec 08             	sub    $0x8,%esp
80103009:	50                   	push   %eax
8010300a:	68 d8 87 10 80       	push   $0x801087d8
8010300f:	e8 b0 d3 ff ff       	call   801003c4 <cprintf>
80103014:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80103017:	a1 20 12 11 80       	mov    0x80111220,%eax
8010301c:	85 c0                	test   %eax,%eax
8010301e:	74 0f                	je     8010302f <cpunum+0x52>
    return lapic[ID]>>24;
80103020:	a1 20 12 11 80       	mov    0x80111220,%eax
80103025:	83 c0 20             	add    $0x20,%eax
80103028:	8b 00                	mov    (%eax),%eax
8010302a:	c1 e8 18             	shr    $0x18,%eax
8010302d:	eb 05                	jmp    80103034 <cpunum+0x57>
  return 0;
8010302f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103034:	c9                   	leave
80103035:	c3                   	ret

80103036 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103036:	55                   	push   %ebp
80103037:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103039:	a1 20 12 11 80       	mov    0x80111220,%eax
8010303e:	85 c0                	test   %eax,%eax
80103040:	74 0c                	je     8010304e <lapiceoi+0x18>
    lapicw(EOI, 0);
80103042:	6a 00                	push   $0x0
80103044:	6a 2c                	push   $0x2c
80103046:	e8 54 fe ff ff       	call   80102e9f <lapicw>
8010304b:	83 c4 08             	add    $0x8,%esp
}
8010304e:	90                   	nop
8010304f:	c9                   	leave
80103050:	c3                   	ret

80103051 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103051:	55                   	push   %ebp
80103052:	89 e5                	mov    %esp,%ebp
}
80103054:	90                   	nop
80103055:	5d                   	pop    %ebp
80103056:	c3                   	ret

80103057 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103057:	55                   	push   %ebp
80103058:	89 e5                	mov    %esp,%ebp
8010305a:	83 ec 14             	sub    $0x14,%esp
8010305d:	8b 45 08             	mov    0x8(%ebp),%eax
80103060:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103063:	6a 0f                	push   $0xf
80103065:	6a 70                	push   $0x70
80103067:	e8 04 fe ff ff       	call   80102e70 <outb>
8010306c:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010306f:	6a 0a                	push   $0xa
80103071:	6a 71                	push   $0x71
80103073:	e8 f8 fd ff ff       	call   80102e70 <outb>
80103078:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010307b:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103082:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103085:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010308a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010308d:	c1 e8 04             	shr    $0x4,%eax
80103090:	89 c2                	mov    %eax,%edx
80103092:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103095:	83 c0 02             	add    $0x2,%eax
80103098:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010309b:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010309f:	c1 e0 18             	shl    $0x18,%eax
801030a2:	50                   	push   %eax
801030a3:	68 c4 00 00 00       	push   $0xc4
801030a8:	e8 f2 fd ff ff       	call   80102e9f <lapicw>
801030ad:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801030b0:	68 00 c5 00 00       	push   $0xc500
801030b5:	68 c0 00 00 00       	push   $0xc0
801030ba:	e8 e0 fd ff ff       	call   80102e9f <lapicw>
801030bf:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801030c2:	68 c8 00 00 00       	push   $0xc8
801030c7:	e8 85 ff ff ff       	call   80103051 <microdelay>
801030cc:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801030cf:	68 00 85 00 00       	push   $0x8500
801030d4:	68 c0 00 00 00       	push   $0xc0
801030d9:	e8 c1 fd ff ff       	call   80102e9f <lapicw>
801030de:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030e1:	6a 64                	push   $0x64
801030e3:	e8 69 ff ff ff       	call   80103051 <microdelay>
801030e8:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030eb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030f2:	eb 3d                	jmp    80103131 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
801030f4:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030f8:	c1 e0 18             	shl    $0x18,%eax
801030fb:	50                   	push   %eax
801030fc:	68 c4 00 00 00       	push   $0xc4
80103101:	e8 99 fd ff ff       	call   80102e9f <lapicw>
80103106:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103109:	8b 45 0c             	mov    0xc(%ebp),%eax
8010310c:	c1 e8 0c             	shr    $0xc,%eax
8010310f:	80 cc 06             	or     $0x6,%ah
80103112:	50                   	push   %eax
80103113:	68 c0 00 00 00       	push   $0xc0
80103118:	e8 82 fd ff ff       	call   80102e9f <lapicw>
8010311d:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103120:	68 c8 00 00 00       	push   $0xc8
80103125:	e8 27 ff ff ff       	call   80103051 <microdelay>
8010312a:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
8010312d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103131:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103135:	7e bd                	jle    801030f4 <lapicstartap+0x9d>
  }
}
80103137:	90                   	nop
80103138:	90                   	nop
80103139:	c9                   	leave
8010313a:	c3                   	ret

8010313b <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010313b:	55                   	push   %ebp
8010313c:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010313e:	8b 45 08             	mov    0x8(%ebp),%eax
80103141:	0f b6 c0             	movzbl %al,%eax
80103144:	50                   	push   %eax
80103145:	6a 70                	push   $0x70
80103147:	e8 24 fd ff ff       	call   80102e70 <outb>
8010314c:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010314f:	68 c8 00 00 00       	push   $0xc8
80103154:	e8 f8 fe ff ff       	call   80103051 <microdelay>
80103159:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010315c:	6a 71                	push   $0x71
8010315e:	e8 f0 fc ff ff       	call   80102e53 <inb>
80103163:	83 c4 04             	add    $0x4,%esp
80103166:	0f b6 c0             	movzbl %al,%eax
}
80103169:	c9                   	leave
8010316a:	c3                   	ret

8010316b <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010316b:	55                   	push   %ebp
8010316c:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010316e:	6a 00                	push   $0x0
80103170:	e8 c6 ff ff ff       	call   8010313b <cmos_read>
80103175:	83 c4 04             	add    $0x4,%esp
80103178:	8b 55 08             	mov    0x8(%ebp),%edx
8010317b:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010317d:	6a 02                	push   $0x2
8010317f:	e8 b7 ff ff ff       	call   8010313b <cmos_read>
80103184:	83 c4 04             	add    $0x4,%esp
80103187:	8b 55 08             	mov    0x8(%ebp),%edx
8010318a:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
8010318d:	6a 04                	push   $0x4
8010318f:	e8 a7 ff ff ff       	call   8010313b <cmos_read>
80103194:	83 c4 04             	add    $0x4,%esp
80103197:	8b 55 08             	mov    0x8(%ebp),%edx
8010319a:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
8010319d:	6a 07                	push   $0x7
8010319f:	e8 97 ff ff ff       	call   8010313b <cmos_read>
801031a4:	83 c4 04             	add    $0x4,%esp
801031a7:	8b 55 08             	mov    0x8(%ebp),%edx
801031aa:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801031ad:	6a 08                	push   $0x8
801031af:	e8 87 ff ff ff       	call   8010313b <cmos_read>
801031b4:	83 c4 04             	add    $0x4,%esp
801031b7:	8b 55 08             	mov    0x8(%ebp),%edx
801031ba:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801031bd:	6a 09                	push   $0x9
801031bf:	e8 77 ff ff ff       	call   8010313b <cmos_read>
801031c4:	83 c4 04             	add    $0x4,%esp
801031c7:	8b 55 08             	mov    0x8(%ebp),%edx
801031ca:	89 42 14             	mov    %eax,0x14(%edx)
}
801031cd:	90                   	nop
801031ce:	c9                   	leave
801031cf:	c3                   	ret

801031d0 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801031d0:	55                   	push   %ebp
801031d1:	89 e5                	mov    %esp,%ebp
801031d3:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031d6:	6a 0b                	push   $0xb
801031d8:	e8 5e ff ff ff       	call   8010313b <cmos_read>
801031dd:	83 c4 04             	add    $0x4,%esp
801031e0:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031e6:	83 e0 04             	and    $0x4,%eax
801031e9:	85 c0                	test   %eax,%eax
801031eb:	0f 94 c0             	sete   %al
801031ee:	0f b6 c0             	movzbl %al,%eax
801031f1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801031f4:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031f7:	50                   	push   %eax
801031f8:	e8 6e ff ff ff       	call   8010316b <fill_rtcdate>
801031fd:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103200:	6a 0a                	push   $0xa
80103202:	e8 34 ff ff ff       	call   8010313b <cmos_read>
80103207:	83 c4 04             	add    $0x4,%esp
8010320a:	25 80 00 00 00       	and    $0x80,%eax
8010320f:	85 c0                	test   %eax,%eax
80103211:	75 27                	jne    8010323a <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80103213:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103216:	50                   	push   %eax
80103217:	e8 4f ff ff ff       	call   8010316b <fill_rtcdate>
8010321c:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
8010321f:	83 ec 04             	sub    $0x4,%esp
80103222:	6a 18                	push   $0x18
80103224:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103227:	50                   	push   %eax
80103228:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010322b:	50                   	push   %eax
8010322c:	e8 fc 20 00 00       	call   8010532d <memcmp>
80103231:	83 c4 10             	add    $0x10,%esp
80103234:	85 c0                	test   %eax,%eax
80103236:	74 05                	je     8010323d <cmostime+0x6d>
80103238:	eb ba                	jmp    801031f4 <cmostime+0x24>
        continue;
8010323a:	90                   	nop
    fill_rtcdate(&t1);
8010323b:	eb b7                	jmp    801031f4 <cmostime+0x24>
      break;
8010323d:	90                   	nop
  }

  // convert
  if (bcd) {
8010323e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103242:	0f 84 b4 00 00 00    	je     801032fc <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103248:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010324b:	c1 e8 04             	shr    $0x4,%eax
8010324e:	89 c2                	mov    %eax,%edx
80103250:	89 d0                	mov    %edx,%eax
80103252:	c1 e0 02             	shl    $0x2,%eax
80103255:	01 d0                	add    %edx,%eax
80103257:	01 c0                	add    %eax,%eax
80103259:	89 c2                	mov    %eax,%edx
8010325b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010325e:	83 e0 0f             	and    $0xf,%eax
80103261:	01 d0                	add    %edx,%eax
80103263:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103266:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103269:	c1 e8 04             	shr    $0x4,%eax
8010326c:	89 c2                	mov    %eax,%edx
8010326e:	89 d0                	mov    %edx,%eax
80103270:	c1 e0 02             	shl    $0x2,%eax
80103273:	01 d0                	add    %edx,%eax
80103275:	01 c0                	add    %eax,%eax
80103277:	89 c2                	mov    %eax,%edx
80103279:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010327c:	83 e0 0f             	and    $0xf,%eax
8010327f:	01 d0                	add    %edx,%eax
80103281:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103284:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103287:	c1 e8 04             	shr    $0x4,%eax
8010328a:	89 c2                	mov    %eax,%edx
8010328c:	89 d0                	mov    %edx,%eax
8010328e:	c1 e0 02             	shl    $0x2,%eax
80103291:	01 d0                	add    %edx,%eax
80103293:	01 c0                	add    %eax,%eax
80103295:	89 c2                	mov    %eax,%edx
80103297:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010329a:	83 e0 0f             	and    $0xf,%eax
8010329d:	01 d0                	add    %edx,%eax
8010329f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801032a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032a5:	c1 e8 04             	shr    $0x4,%eax
801032a8:	89 c2                	mov    %eax,%edx
801032aa:	89 d0                	mov    %edx,%eax
801032ac:	c1 e0 02             	shl    $0x2,%eax
801032af:	01 d0                	add    %edx,%eax
801032b1:	01 c0                	add    %eax,%eax
801032b3:	89 c2                	mov    %eax,%edx
801032b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032b8:	83 e0 0f             	and    $0xf,%eax
801032bb:	01 d0                	add    %edx,%eax
801032bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801032c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032c3:	c1 e8 04             	shr    $0x4,%eax
801032c6:	89 c2                	mov    %eax,%edx
801032c8:	89 d0                	mov    %edx,%eax
801032ca:	c1 e0 02             	shl    $0x2,%eax
801032cd:	01 d0                	add    %edx,%eax
801032cf:	01 c0                	add    %eax,%eax
801032d1:	89 c2                	mov    %eax,%edx
801032d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032d6:	83 e0 0f             	and    $0xf,%eax
801032d9:	01 d0                	add    %edx,%eax
801032db:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032e1:	c1 e8 04             	shr    $0x4,%eax
801032e4:	89 c2                	mov    %eax,%edx
801032e6:	89 d0                	mov    %edx,%eax
801032e8:	c1 e0 02             	shl    $0x2,%eax
801032eb:	01 d0                	add    %edx,%eax
801032ed:	01 c0                	add    %eax,%eax
801032ef:	89 c2                	mov    %eax,%edx
801032f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032f4:	83 e0 0f             	and    $0xf,%eax
801032f7:	01 d0                	add    %edx,%eax
801032f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032fc:	8b 45 08             	mov    0x8(%ebp),%eax
801032ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103302:	89 10                	mov    %edx,(%eax)
80103304:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103307:	89 50 04             	mov    %edx,0x4(%eax)
8010330a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010330d:	89 50 08             	mov    %edx,0x8(%eax)
80103310:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103313:	89 50 0c             	mov    %edx,0xc(%eax)
80103316:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103319:	89 50 10             	mov    %edx,0x10(%eax)
8010331c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010331f:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103322:	8b 45 08             	mov    0x8(%ebp),%eax
80103325:	8b 40 14             	mov    0x14(%eax),%eax
80103328:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010332e:	8b 45 08             	mov    0x8(%ebp),%eax
80103331:	89 50 14             	mov    %edx,0x14(%eax)
}
80103334:	90                   	nop
80103335:	c9                   	leave
80103336:	c3                   	ret

80103337 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103337:	55                   	push   %ebp
80103338:	89 e5                	mov    %esp,%ebp
8010333a:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010333d:	83 ec 08             	sub    $0x8,%esp
80103340:	68 04 88 10 80       	push   $0x80108804
80103345:	68 40 12 11 80       	push   $0x80111240
8010334a:	e8 f1 1c 00 00       	call   80105040 <initlock>
8010334f:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103352:	83 ec 08             	sub    $0x8,%esp
80103355:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103358:	50                   	push   %eax
80103359:	ff 75 08             	push   0x8(%ebp)
8010335c:	e8 54 e0 ff ff       	call   801013b5 <readsb>
80103361:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103364:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103367:	a3 74 12 11 80       	mov    %eax,0x80111274
  log.size = sb.nlog;
8010336c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010336f:	a3 78 12 11 80       	mov    %eax,0x80111278
  log.dev = dev;
80103374:	8b 45 08             	mov    0x8(%ebp),%eax
80103377:	a3 84 12 11 80       	mov    %eax,0x80111284
  recover_from_log();
8010337c:	e8 b3 01 00 00       	call   80103534 <recover_from_log>
}
80103381:	90                   	nop
80103382:	c9                   	leave
80103383:	c3                   	ret

80103384 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103384:	55                   	push   %ebp
80103385:	89 e5                	mov    %esp,%ebp
80103387:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010338a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103391:	e9 95 00 00 00       	jmp    8010342b <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103396:	8b 15 74 12 11 80    	mov    0x80111274,%edx
8010339c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010339f:	01 d0                	add    %edx,%eax
801033a1:	83 c0 01             	add    $0x1,%eax
801033a4:	89 c2                	mov    %eax,%edx
801033a6:	a1 84 12 11 80       	mov    0x80111284,%eax
801033ab:	83 ec 08             	sub    $0x8,%esp
801033ae:	52                   	push   %edx
801033af:	50                   	push   %eax
801033b0:	e8 02 ce ff ff       	call   801001b7 <bread>
801033b5:	83 c4 10             	add    $0x10,%esp
801033b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801033bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033be:	83 c0 10             	add    $0x10,%eax
801033c1:	8b 04 85 4c 12 11 80 	mov    -0x7feeedb4(,%eax,4),%eax
801033c8:	89 c2                	mov    %eax,%edx
801033ca:	a1 84 12 11 80       	mov    0x80111284,%eax
801033cf:	83 ec 08             	sub    $0x8,%esp
801033d2:	52                   	push   %edx
801033d3:	50                   	push   %eax
801033d4:	e8 de cd ff ff       	call   801001b7 <bread>
801033d9:	83 c4 10             	add    $0x10,%esp
801033dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033e2:	8d 50 18             	lea    0x18(%eax),%edx
801033e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033e8:	83 c0 18             	add    $0x18,%eax
801033eb:	83 ec 04             	sub    $0x4,%esp
801033ee:	68 00 02 00 00       	push   $0x200
801033f3:	52                   	push   %edx
801033f4:	50                   	push   %eax
801033f5:	e8 8b 1f 00 00       	call   80105385 <memmove>
801033fa:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033fd:	83 ec 0c             	sub    $0xc,%esp
80103400:	ff 75 ec             	push   -0x14(%ebp)
80103403:	e8 e8 cd ff ff       	call   801001f0 <bwrite>
80103408:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
8010340b:	83 ec 0c             	sub    $0xc,%esp
8010340e:	ff 75 f0             	push   -0x10(%ebp)
80103411:	e8 19 ce ff ff       	call   8010022f <brelse>
80103416:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103419:	83 ec 0c             	sub    $0xc,%esp
8010341c:	ff 75 ec             	push   -0x14(%ebp)
8010341f:	e8 0b ce ff ff       	call   8010022f <brelse>
80103424:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103427:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010342b:	a1 88 12 11 80       	mov    0x80111288,%eax
80103430:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103433:	0f 8c 5d ff ff ff    	jl     80103396 <install_trans+0x12>
  }
}
80103439:	90                   	nop
8010343a:	90                   	nop
8010343b:	c9                   	leave
8010343c:	c3                   	ret

8010343d <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010343d:	55                   	push   %ebp
8010343e:	89 e5                	mov    %esp,%ebp
80103440:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103443:	a1 74 12 11 80       	mov    0x80111274,%eax
80103448:	89 c2                	mov    %eax,%edx
8010344a:	a1 84 12 11 80       	mov    0x80111284,%eax
8010344f:	83 ec 08             	sub    $0x8,%esp
80103452:	52                   	push   %edx
80103453:	50                   	push   %eax
80103454:	e8 5e cd ff ff       	call   801001b7 <bread>
80103459:	83 c4 10             	add    $0x10,%esp
8010345c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010345f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103462:	83 c0 18             	add    $0x18,%eax
80103465:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103468:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010346b:	8b 00                	mov    (%eax),%eax
8010346d:	a3 88 12 11 80       	mov    %eax,0x80111288
  for (i = 0; i < log.lh.n; i++) {
80103472:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103479:	eb 1b                	jmp    80103496 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
8010347b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010347e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103481:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103485:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103488:	83 c2 10             	add    $0x10,%edx
8010348b:	89 04 95 4c 12 11 80 	mov    %eax,-0x7feeedb4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103492:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103496:	a1 88 12 11 80       	mov    0x80111288,%eax
8010349b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010349e:	7c db                	jl     8010347b <read_head+0x3e>
  }
  brelse(buf);
801034a0:	83 ec 0c             	sub    $0xc,%esp
801034a3:	ff 75 f0             	push   -0x10(%ebp)
801034a6:	e8 84 cd ff ff       	call   8010022f <brelse>
801034ab:	83 c4 10             	add    $0x10,%esp
}
801034ae:	90                   	nop
801034af:	c9                   	leave
801034b0:	c3                   	ret

801034b1 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034b1:	55                   	push   %ebp
801034b2:	89 e5                	mov    %esp,%ebp
801034b4:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034b7:	a1 74 12 11 80       	mov    0x80111274,%eax
801034bc:	89 c2                	mov    %eax,%edx
801034be:	a1 84 12 11 80       	mov    0x80111284,%eax
801034c3:	83 ec 08             	sub    $0x8,%esp
801034c6:	52                   	push   %edx
801034c7:	50                   	push   %eax
801034c8:	e8 ea cc ff ff       	call   801001b7 <bread>
801034cd:	83 c4 10             	add    $0x10,%esp
801034d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d6:	83 c0 18             	add    $0x18,%eax
801034d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034dc:	8b 15 88 12 11 80    	mov    0x80111288,%edx
801034e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034e5:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034ee:	eb 1b                	jmp    8010350b <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f3:	83 c0 10             	add    $0x10,%eax
801034f6:	8b 0c 85 4c 12 11 80 	mov    -0x7feeedb4(,%eax,4),%ecx
801034fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103500:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103503:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103507:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010350b:	a1 88 12 11 80       	mov    0x80111288,%eax
80103510:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103513:	7c db                	jl     801034f0 <write_head+0x3f>
  }
  bwrite(buf);
80103515:	83 ec 0c             	sub    $0xc,%esp
80103518:	ff 75 f0             	push   -0x10(%ebp)
8010351b:	e8 d0 cc ff ff       	call   801001f0 <bwrite>
80103520:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103523:	83 ec 0c             	sub    $0xc,%esp
80103526:	ff 75 f0             	push   -0x10(%ebp)
80103529:	e8 01 cd ff ff       	call   8010022f <brelse>
8010352e:	83 c4 10             	add    $0x10,%esp
}
80103531:	90                   	nop
80103532:	c9                   	leave
80103533:	c3                   	ret

80103534 <recover_from_log>:

static void
recover_from_log(void)
{
80103534:	55                   	push   %ebp
80103535:	89 e5                	mov    %esp,%ebp
80103537:	83 ec 08             	sub    $0x8,%esp
  read_head();      
8010353a:	e8 fe fe ff ff       	call   8010343d <read_head>
  install_trans(); // if committed, copy from log to disk
8010353f:	e8 40 fe ff ff       	call   80103384 <install_trans>
  log.lh.n = 0;
80103544:	c7 05 88 12 11 80 00 	movl   $0x0,0x80111288
8010354b:	00 00 00 
  write_head(); // clear the log
8010354e:	e8 5e ff ff ff       	call   801034b1 <write_head>
}
80103553:	90                   	nop
80103554:	c9                   	leave
80103555:	c3                   	ret

80103556 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103556:	55                   	push   %ebp
80103557:	89 e5                	mov    %esp,%ebp
80103559:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010355c:	83 ec 0c             	sub    $0xc,%esp
8010355f:	68 40 12 11 80       	push   $0x80111240
80103564:	e8 f9 1a 00 00       	call   80105062 <acquire>
80103569:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010356c:	a1 80 12 11 80       	mov    0x80111280,%eax
80103571:	85 c0                	test   %eax,%eax
80103573:	74 17                	je     8010358c <begin_op+0x36>
      sleep(&log, &log.lock);
80103575:	83 ec 08             	sub    $0x8,%esp
80103578:	68 40 12 11 80       	push   $0x80111240
8010357d:	68 40 12 11 80       	push   $0x80111240
80103582:	e8 e0 17 00 00       	call   80104d67 <sleep>
80103587:	83 c4 10             	add    $0x10,%esp
8010358a:	eb e0                	jmp    8010356c <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010358c:	8b 0d 88 12 11 80    	mov    0x80111288,%ecx
80103592:	a1 7c 12 11 80       	mov    0x8011127c,%eax
80103597:	8d 50 01             	lea    0x1(%eax),%edx
8010359a:	89 d0                	mov    %edx,%eax
8010359c:	c1 e0 02             	shl    $0x2,%eax
8010359f:	01 d0                	add    %edx,%eax
801035a1:	01 c0                	add    %eax,%eax
801035a3:	01 c8                	add    %ecx,%eax
801035a5:	83 f8 1e             	cmp    $0x1e,%eax
801035a8:	7e 17                	jle    801035c1 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801035aa:	83 ec 08             	sub    $0x8,%esp
801035ad:	68 40 12 11 80       	push   $0x80111240
801035b2:	68 40 12 11 80       	push   $0x80111240
801035b7:	e8 ab 17 00 00       	call   80104d67 <sleep>
801035bc:	83 c4 10             	add    $0x10,%esp
801035bf:	eb ab                	jmp    8010356c <begin_op+0x16>
    } else {
      log.outstanding += 1;
801035c1:	a1 7c 12 11 80       	mov    0x8011127c,%eax
801035c6:	83 c0 01             	add    $0x1,%eax
801035c9:	a3 7c 12 11 80       	mov    %eax,0x8011127c
      release(&log.lock);
801035ce:	83 ec 0c             	sub    $0xc,%esp
801035d1:	68 40 12 11 80       	push   $0x80111240
801035d6:	e8 ee 1a 00 00       	call   801050c9 <release>
801035db:	83 c4 10             	add    $0x10,%esp
      break;
801035de:	90                   	nop
    }
  }
}
801035df:	90                   	nop
801035e0:	c9                   	leave
801035e1:	c3                   	ret

801035e2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035e2:	55                   	push   %ebp
801035e3:	89 e5                	mov    %esp,%ebp
801035e5:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035ef:	83 ec 0c             	sub    $0xc,%esp
801035f2:	68 40 12 11 80       	push   $0x80111240
801035f7:	e8 66 1a 00 00       	call   80105062 <acquire>
801035fc:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035ff:	a1 7c 12 11 80       	mov    0x8011127c,%eax
80103604:	83 e8 01             	sub    $0x1,%eax
80103607:	a3 7c 12 11 80       	mov    %eax,0x8011127c
  if(log.committing)
8010360c:	a1 80 12 11 80       	mov    0x80111280,%eax
80103611:	85 c0                	test   %eax,%eax
80103613:	74 0d                	je     80103622 <end_op+0x40>
    panic("log.committing");
80103615:	83 ec 0c             	sub    $0xc,%esp
80103618:	68 08 88 10 80       	push   $0x80108808
8010361d:	e8 57 cf ff ff       	call   80100579 <panic>
  if(log.outstanding == 0){
80103622:	a1 7c 12 11 80       	mov    0x8011127c,%eax
80103627:	85 c0                	test   %eax,%eax
80103629:	75 13                	jne    8010363e <end_op+0x5c>
    do_commit = 1;
8010362b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103632:	c7 05 80 12 11 80 01 	movl   $0x1,0x80111280
80103639:	00 00 00 
8010363c:	eb 10                	jmp    8010364e <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
8010363e:	83 ec 0c             	sub    $0xc,%esp
80103641:	68 40 12 11 80       	push   $0x80111240
80103646:	e8 08 18 00 00       	call   80104e53 <wakeup>
8010364b:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010364e:	83 ec 0c             	sub    $0xc,%esp
80103651:	68 40 12 11 80       	push   $0x80111240
80103656:	e8 6e 1a 00 00       	call   801050c9 <release>
8010365b:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010365e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103662:	74 3f                	je     801036a3 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103664:	e8 f6 00 00 00       	call   8010375f <commit>
    acquire(&log.lock);
80103669:	83 ec 0c             	sub    $0xc,%esp
8010366c:	68 40 12 11 80       	push   $0x80111240
80103671:	e8 ec 19 00 00       	call   80105062 <acquire>
80103676:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103679:	c7 05 80 12 11 80 00 	movl   $0x0,0x80111280
80103680:	00 00 00 
    wakeup(&log);
80103683:	83 ec 0c             	sub    $0xc,%esp
80103686:	68 40 12 11 80       	push   $0x80111240
8010368b:	e8 c3 17 00 00       	call   80104e53 <wakeup>
80103690:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103693:	83 ec 0c             	sub    $0xc,%esp
80103696:	68 40 12 11 80       	push   $0x80111240
8010369b:	e8 29 1a 00 00       	call   801050c9 <release>
801036a0:	83 c4 10             	add    $0x10,%esp
  }
}
801036a3:	90                   	nop
801036a4:	c9                   	leave
801036a5:	c3                   	ret

801036a6 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801036a6:	55                   	push   %ebp
801036a7:	89 e5                	mov    %esp,%ebp
801036a9:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036b3:	e9 95 00 00 00       	jmp    8010374d <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801036b8:	8b 15 74 12 11 80    	mov    0x80111274,%edx
801036be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036c1:	01 d0                	add    %edx,%eax
801036c3:	83 c0 01             	add    $0x1,%eax
801036c6:	89 c2                	mov    %eax,%edx
801036c8:	a1 84 12 11 80       	mov    0x80111284,%eax
801036cd:	83 ec 08             	sub    $0x8,%esp
801036d0:	52                   	push   %edx
801036d1:	50                   	push   %eax
801036d2:	e8 e0 ca ff ff       	call   801001b7 <bread>
801036d7:	83 c4 10             	add    $0x10,%esp
801036da:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036e0:	83 c0 10             	add    $0x10,%eax
801036e3:	8b 04 85 4c 12 11 80 	mov    -0x7feeedb4(,%eax,4),%eax
801036ea:	89 c2                	mov    %eax,%edx
801036ec:	a1 84 12 11 80       	mov    0x80111284,%eax
801036f1:	83 ec 08             	sub    $0x8,%esp
801036f4:	52                   	push   %edx
801036f5:	50                   	push   %eax
801036f6:	e8 bc ca ff ff       	call   801001b7 <bread>
801036fb:	83 c4 10             	add    $0x10,%esp
801036fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103701:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103704:	8d 50 18             	lea    0x18(%eax),%edx
80103707:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010370a:	83 c0 18             	add    $0x18,%eax
8010370d:	83 ec 04             	sub    $0x4,%esp
80103710:	68 00 02 00 00       	push   $0x200
80103715:	52                   	push   %edx
80103716:	50                   	push   %eax
80103717:	e8 69 1c 00 00       	call   80105385 <memmove>
8010371c:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
8010371f:	83 ec 0c             	sub    $0xc,%esp
80103722:	ff 75 f0             	push   -0x10(%ebp)
80103725:	e8 c6 ca ff ff       	call   801001f0 <bwrite>
8010372a:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
8010372d:	83 ec 0c             	sub    $0xc,%esp
80103730:	ff 75 ec             	push   -0x14(%ebp)
80103733:	e8 f7 ca ff ff       	call   8010022f <brelse>
80103738:	83 c4 10             	add    $0x10,%esp
    brelse(to);
8010373b:	83 ec 0c             	sub    $0xc,%esp
8010373e:	ff 75 f0             	push   -0x10(%ebp)
80103741:	e8 e9 ca ff ff       	call   8010022f <brelse>
80103746:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103749:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010374d:	a1 88 12 11 80       	mov    0x80111288,%eax
80103752:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103755:	0f 8c 5d ff ff ff    	jl     801036b8 <write_log+0x12>
  }
}
8010375b:	90                   	nop
8010375c:	90                   	nop
8010375d:	c9                   	leave
8010375e:	c3                   	ret

8010375f <commit>:

static void
commit()
{
8010375f:	55                   	push   %ebp
80103760:	89 e5                	mov    %esp,%ebp
80103762:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103765:	a1 88 12 11 80       	mov    0x80111288,%eax
8010376a:	85 c0                	test   %eax,%eax
8010376c:	7e 1e                	jle    8010378c <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010376e:	e8 33 ff ff ff       	call   801036a6 <write_log>
    write_head();    // Write header to disk -- the real commit
80103773:	e8 39 fd ff ff       	call   801034b1 <write_head>
    install_trans(); // Now install writes to home locations
80103778:	e8 07 fc ff ff       	call   80103384 <install_trans>
    log.lh.n = 0; 
8010377d:	c7 05 88 12 11 80 00 	movl   $0x0,0x80111288
80103784:	00 00 00 
    write_head();    // Erase the transaction from the log
80103787:	e8 25 fd ff ff       	call   801034b1 <write_head>
  }
}
8010378c:	90                   	nop
8010378d:	c9                   	leave
8010378e:	c3                   	ret

8010378f <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010378f:	55                   	push   %ebp
80103790:	89 e5                	mov    %esp,%ebp
80103792:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103795:	a1 88 12 11 80       	mov    0x80111288,%eax
8010379a:	83 f8 1d             	cmp    $0x1d,%eax
8010379d:	7f 12                	jg     801037b1 <log_write+0x22>
8010379f:	8b 15 88 12 11 80    	mov    0x80111288,%edx
801037a5:	a1 78 12 11 80       	mov    0x80111278,%eax
801037aa:	83 e8 01             	sub    $0x1,%eax
801037ad:	39 c2                	cmp    %eax,%edx
801037af:	7c 0d                	jl     801037be <log_write+0x2f>
    panic("too big a transaction");
801037b1:	83 ec 0c             	sub    $0xc,%esp
801037b4:	68 17 88 10 80       	push   $0x80108817
801037b9:	e8 bb cd ff ff       	call   80100579 <panic>
  if (log.outstanding < 1)
801037be:	a1 7c 12 11 80       	mov    0x8011127c,%eax
801037c3:	85 c0                	test   %eax,%eax
801037c5:	7f 0d                	jg     801037d4 <log_write+0x45>
    panic("log_write outside of trans");
801037c7:	83 ec 0c             	sub    $0xc,%esp
801037ca:	68 2d 88 10 80       	push   $0x8010882d
801037cf:	e8 a5 cd ff ff       	call   80100579 <panic>

  acquire(&log.lock);
801037d4:	83 ec 0c             	sub    $0xc,%esp
801037d7:	68 40 12 11 80       	push   $0x80111240
801037dc:	e8 81 18 00 00       	call   80105062 <acquire>
801037e1:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037eb:	eb 1d                	jmp    8010380a <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037f0:	83 c0 10             	add    $0x10,%eax
801037f3:	8b 04 85 4c 12 11 80 	mov    -0x7feeedb4(,%eax,4),%eax
801037fa:	89 c2                	mov    %eax,%edx
801037fc:	8b 45 08             	mov    0x8(%ebp),%eax
801037ff:	8b 40 08             	mov    0x8(%eax),%eax
80103802:	39 c2                	cmp    %eax,%edx
80103804:	74 10                	je     80103816 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
80103806:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010380a:	a1 88 12 11 80       	mov    0x80111288,%eax
8010380f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103812:	7c d9                	jl     801037ed <log_write+0x5e>
80103814:	eb 01                	jmp    80103817 <log_write+0x88>
      break;
80103816:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103817:	8b 45 08             	mov    0x8(%ebp),%eax
8010381a:	8b 40 08             	mov    0x8(%eax),%eax
8010381d:	89 c2                	mov    %eax,%edx
8010381f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103822:	83 c0 10             	add    $0x10,%eax
80103825:	89 14 85 4c 12 11 80 	mov    %edx,-0x7feeedb4(,%eax,4)
  if (i == log.lh.n)
8010382c:	a1 88 12 11 80       	mov    0x80111288,%eax
80103831:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103834:	75 0d                	jne    80103843 <log_write+0xb4>
    log.lh.n++;
80103836:	a1 88 12 11 80       	mov    0x80111288,%eax
8010383b:	83 c0 01             	add    $0x1,%eax
8010383e:	a3 88 12 11 80       	mov    %eax,0x80111288
  b->flags |= B_DIRTY; // prevent eviction
80103843:	8b 45 08             	mov    0x8(%ebp),%eax
80103846:	8b 00                	mov    (%eax),%eax
80103848:	83 c8 04             	or     $0x4,%eax
8010384b:	89 c2                	mov    %eax,%edx
8010384d:	8b 45 08             	mov    0x8(%ebp),%eax
80103850:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103852:	83 ec 0c             	sub    $0xc,%esp
80103855:	68 40 12 11 80       	push   $0x80111240
8010385a:	e8 6a 18 00 00       	call   801050c9 <release>
8010385f:	83 c4 10             	add    $0x10,%esp
}
80103862:	90                   	nop
80103863:	c9                   	leave
80103864:	c3                   	ret

80103865 <v2p>:
80103865:	55                   	push   %ebp
80103866:	89 e5                	mov    %esp,%ebp
80103868:	8b 45 08             	mov    0x8(%ebp),%eax
8010386b:	05 00 00 00 80       	add    $0x80000000,%eax
80103870:	5d                   	pop    %ebp
80103871:	c3                   	ret

80103872 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103872:	55                   	push   %ebp
80103873:	89 e5                	mov    %esp,%ebp
80103875:	8b 45 08             	mov    0x8(%ebp),%eax
80103878:	05 00 00 00 80       	add    $0x80000000,%eax
8010387d:	5d                   	pop    %ebp
8010387e:	c3                   	ret

8010387f <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010387f:	55                   	push   %ebp
80103880:	89 e5                	mov    %esp,%ebp
80103882:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103885:	8b 55 08             	mov    0x8(%ebp),%edx
80103888:	8b 45 0c             	mov    0xc(%ebp),%eax
8010388b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010388e:	f0 87 02             	lock xchg %eax,(%edx)
80103891:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103894:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103897:	c9                   	leave
80103898:	c3                   	ret

80103899 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103899:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010389d:	83 e4 f0             	and    $0xfffffff0,%esp
801038a0:	ff 71 fc             	push   -0x4(%ecx)
801038a3:	55                   	push   %ebp
801038a4:	89 e5                	mov    %esp,%ebp
801038a6:	51                   	push   %ecx
801038a7:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038aa:	83 ec 08             	sub    $0x8,%esp
801038ad:	68 00 00 40 80       	push   $0x80400000
801038b2:	68 00 51 11 80       	push   $0x80115100
801038b7:	e8 85 f2 ff ff       	call   80102b41 <kinit1>
801038bc:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801038bf:	e8 55 45 00 00       	call   80107e19 <kvmalloc>
  mpinit();        // collect info about this machine
801038c4:	e8 55 04 00 00       	call   80103d1e <mpinit>
  lapicinit();
801038c9:	e8 f3 f5 ff ff       	call   80102ec1 <lapicinit>
  seginit();       // set up segments
801038ce:	e8 ef 3e 00 00       	call   801077c2 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801038d3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038d9:	0f b6 00             	movzbl (%eax),%eax
801038dc:	0f b6 c0             	movzbl %al,%eax
801038df:	83 ec 08             	sub    $0x8,%esp
801038e2:	50                   	push   %eax
801038e3:	68 48 88 10 80       	push   $0x80108848
801038e8:	e8 d7 ca ff ff       	call   801003c4 <cprintf>
801038ed:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
801038f0:	e8 a3 06 00 00       	call   80103f98 <picinit>
  ioapicinit();    // another interrupt controller
801038f5:	e8 3c f1 ff ff       	call   80102a36 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801038fa:	e8 4b d2 ff ff       	call   80100b4a <consoleinit>
  uartinit();      // serial port
801038ff:	e8 1a 32 00 00       	call   80106b1e <uartinit>
  pinit();         // process table
80103904:	e8 93 0b 00 00       	call   8010449c <pinit>
  tvinit();        // trap vectors
80103909:	e8 d9 2d 00 00       	call   801066e7 <tvinit>
  binit();         // buffer cache
8010390e:	e8 21 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103913:	e8 8e d6 ff ff       	call   80100fa6 <fileinit>
  ideinit();       // disk
80103918:	e8 21 ed ff ff       	call   8010263e <ideinit>
  if(!ismp)
8010391d:	a1 00 19 11 80       	mov    0x80111900,%eax
80103922:	85 c0                	test   %eax,%eax
80103924:	75 05                	jne    8010392b <main+0x92>
    timerinit();   // uniprocessor timer
80103926:	e8 19 2d 00 00       	call   80106644 <timerinit>
  startothers();   // start other processors
8010392b:	e8 9c 00 00 00       	call   801039cc <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103930:	83 ec 08             	sub    $0x8,%esp
80103933:	68 00 00 00 8e       	push   $0x8e000000
80103938:	68 00 00 40 80       	push   $0x80400000
8010393d:	e8 38 f2 ff ff       	call   80102b7a <kinit2>
80103942:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103945:	e8 74 0c 00 00       	call   801045be <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
8010394a:	e8 1a 00 00 00       	call   80103969 <mpmain>

8010394f <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010394f:	55                   	push   %ebp
80103950:	89 e5                	mov    %esp,%ebp
80103952:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103955:	e8 d7 44 00 00       	call   80107e31 <switchkvm>
  seginit();
8010395a:	e8 63 3e 00 00       	call   801077c2 <seginit>
  lapicinit();
8010395f:	e8 5d f5 ff ff       	call   80102ec1 <lapicinit>
  mpmain();
80103964:	e8 00 00 00 00       	call   80103969 <mpmain>

80103969 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103969:	55                   	push   %ebp
8010396a:	89 e5                	mov    %esp,%ebp
8010396c:	83 ec 08             	sub    $0x8,%esp
  if(cpu->id==0) cprintf("CSE3320 proj0 printing in kernel space\n");
8010396f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103975:	0f b6 00             	movzbl (%eax),%eax
80103978:	84 c0                	test   %al,%al
8010397a:	75 10                	jne    8010398c <mpmain+0x23>
8010397c:	83 ec 0c             	sub    $0xc,%esp
8010397f:	68 60 88 10 80       	push   $0x80108860
80103984:	e8 3b ca ff ff       	call   801003c4 <cprintf>
80103989:	83 c4 10             	add    $0x10,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010398c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103992:	0f b6 00             	movzbl (%eax),%eax
80103995:	0f b6 c0             	movzbl %al,%eax
80103998:	83 ec 08             	sub    $0x8,%esp
8010399b:	50                   	push   %eax
8010399c:	68 88 88 10 80       	push   $0x80108888
801039a1:	e8 1e ca ff ff       	call   801003c4 <cprintf>
801039a6:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801039a9:	e8 af 2e 00 00       	call   8010685d <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801039ae:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801039b4:	05 a8 00 00 00       	add    $0xa8,%eax
801039b9:	83 ec 08             	sub    $0x8,%esp
801039bc:	6a 01                	push   $0x1
801039be:	50                   	push   %eax
801039bf:	e8 bb fe ff ff       	call   8010387f <xchg>
801039c4:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801039c7:	e8 95 11 00 00       	call   80104b61 <scheduler>

801039cc <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801039cc:	55                   	push   %ebp
801039cd:	89 e5                	mov    %esp,%ebp
801039cf:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801039d2:	68 00 70 00 00       	push   $0x7000
801039d7:	e8 96 fe ff ff       	call   80103872 <p2v>
801039dc:	83 c4 04             	add    $0x4,%esp
801039df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801039e2:	b8 8a 00 00 00       	mov    $0x8a,%eax
801039e7:	83 ec 04             	sub    $0x4,%esp
801039ea:	50                   	push   %eax
801039eb:	68 0c b5 10 80       	push   $0x8010b50c
801039f0:	ff 75 f0             	push   -0x10(%ebp)
801039f3:	e8 8d 19 00 00       	call   80105385 <memmove>
801039f8:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801039fb:	c7 45 f4 20 13 11 80 	movl   $0x80111320,-0xc(%ebp)
80103a02:	e9 8e 00 00 00       	jmp    80103a95 <startothers+0xc9>
    if(c == cpus+cpunum())  // We've started already.
80103a07:	e8 d1 f5 ff ff       	call   80102fdd <cpunum>
80103a0c:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a12:	05 20 13 11 80       	add    $0x80111320,%eax
80103a17:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a1a:	74 71                	je     80103a8d <startothers+0xc1>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103a1c:	e8 58 f2 ff ff       	call   80102c79 <kalloc>
80103a21:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a27:	83 e8 04             	sub    $0x4,%eax
80103a2a:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a2d:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a33:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a38:	83 e8 08             	sub    $0x8,%eax
80103a3b:	c7 00 4f 39 10 80    	movl   $0x8010394f,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103a41:	83 ec 0c             	sub    $0xc,%esp
80103a44:	68 00 a0 10 80       	push   $0x8010a000
80103a49:	e8 17 fe ff ff       	call   80103865 <v2p>
80103a4e:	83 c4 10             	add    $0x10,%esp
80103a51:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103a54:	83 ea 0c             	sub    $0xc,%edx
80103a57:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->id, v2p(code));
80103a59:	83 ec 0c             	sub    $0xc,%esp
80103a5c:	ff 75 f0             	push   -0x10(%ebp)
80103a5f:	e8 01 fe ff ff       	call   80103865 <v2p>
80103a64:	83 c4 10             	add    $0x10,%esp
80103a67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103a6a:	0f b6 12             	movzbl (%edx),%edx
80103a6d:	0f b6 d2             	movzbl %dl,%edx
80103a70:	83 ec 08             	sub    $0x8,%esp
80103a73:	50                   	push   %eax
80103a74:	52                   	push   %edx
80103a75:	e8 dd f5 ff ff       	call   80103057 <lapicstartap>
80103a7a:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a7d:	90                   	nop
80103a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a81:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103a87:	85 c0                	test   %eax,%eax
80103a89:	74 f3                	je     80103a7e <startothers+0xb2>
80103a8b:	eb 01                	jmp    80103a8e <startothers+0xc2>
      continue;
80103a8d:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103a8e:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103a95:	a1 04 19 11 80       	mov    0x80111904,%eax
80103a9a:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103aa0:	05 20 13 11 80       	add    $0x80111320,%eax
80103aa5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103aa8:	0f 82 59 ff ff ff    	jb     80103a07 <startothers+0x3b>
      ;
  }
}
80103aae:	90                   	nop
80103aaf:	90                   	nop
80103ab0:	c9                   	leave
80103ab1:	c3                   	ret

80103ab2 <p2v>:
80103ab2:	55                   	push   %ebp
80103ab3:	89 e5                	mov    %esp,%ebp
80103ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab8:	05 00 00 00 80       	add    $0x80000000,%eax
80103abd:	5d                   	pop    %ebp
80103abe:	c3                   	ret

80103abf <inb>:
{
80103abf:	55                   	push   %ebp
80103ac0:	89 e5                	mov    %esp,%ebp
80103ac2:	83 ec 14             	sub    $0x14,%esp
80103ac5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103acc:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103ad0:	89 c2                	mov    %eax,%edx
80103ad2:	ec                   	in     (%dx),%al
80103ad3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103ad6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103ada:	c9                   	leave
80103adb:	c3                   	ret

80103adc <outb>:
{
80103adc:	55                   	push   %ebp
80103add:	89 e5                	mov    %esp,%ebp
80103adf:	83 ec 08             	sub    $0x8,%esp
80103ae2:	8b 55 08             	mov    0x8(%ebp),%edx
80103ae5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ae8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103aec:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103aef:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103af3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103af7:	ee                   	out    %al,(%dx)
}
80103af8:	90                   	nop
80103af9:	c9                   	leave
80103afa:	c3                   	ret

80103afb <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103afb:	55                   	push   %ebp
80103afc:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103afe:	a1 0c 19 11 80       	mov    0x8011190c,%eax
80103b03:	2d 20 13 11 80       	sub    $0x80111320,%eax
80103b08:	c1 f8 02             	sar    $0x2,%eax
80103b0b:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103b11:	5d                   	pop    %ebp
80103b12:	c3                   	ret

80103b13 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103b13:	55                   	push   %ebp
80103b14:	89 e5                	mov    %esp,%ebp
80103b16:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103b19:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b20:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b27:	eb 15                	jmp    80103b3e <sum+0x2b>
    sum += addr[i];
80103b29:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80103b2f:	01 d0                	add    %edx,%eax
80103b31:	0f b6 00             	movzbl (%eax),%eax
80103b34:	0f b6 c0             	movzbl %al,%eax
80103b37:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b3a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103b3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b41:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b44:	7c e3                	jl     80103b29 <sum+0x16>
  return sum;
80103b46:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b49:	c9                   	leave
80103b4a:	c3                   	ret

80103b4b <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b4b:	55                   	push   %ebp
80103b4c:	89 e5                	mov    %esp,%ebp
80103b4e:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103b51:	ff 75 08             	push   0x8(%ebp)
80103b54:	e8 59 ff ff ff       	call   80103ab2 <p2v>
80103b59:	83 c4 04             	add    $0x4,%esp
80103b5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b5f:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b65:	01 d0                	add    %edx,%eax
80103b67:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b70:	eb 36                	jmp    80103ba8 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b72:	83 ec 04             	sub    $0x4,%esp
80103b75:	6a 04                	push   $0x4
80103b77:	68 9c 88 10 80       	push   $0x8010889c
80103b7c:	ff 75 f4             	push   -0xc(%ebp)
80103b7f:	e8 a9 17 00 00       	call   8010532d <memcmp>
80103b84:	83 c4 10             	add    $0x10,%esp
80103b87:	85 c0                	test   %eax,%eax
80103b89:	75 19                	jne    80103ba4 <mpsearch1+0x59>
80103b8b:	83 ec 08             	sub    $0x8,%esp
80103b8e:	6a 10                	push   $0x10
80103b90:	ff 75 f4             	push   -0xc(%ebp)
80103b93:	e8 7b ff ff ff       	call   80103b13 <sum>
80103b98:	83 c4 10             	add    $0x10,%esp
80103b9b:	84 c0                	test   %al,%al
80103b9d:	75 05                	jne    80103ba4 <mpsearch1+0x59>
      return (struct mp*)p;
80103b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba2:	eb 11                	jmp    80103bb5 <mpsearch1+0x6a>
  for(p = addr; p < e; p += sizeof(struct mp))
80103ba4:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bab:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103bae:	72 c2                	jb     80103b72 <mpsearch1+0x27>
  return 0;
80103bb0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103bb5:	c9                   	leave
80103bb6:	c3                   	ret

80103bb7 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103bb7:	55                   	push   %ebp
80103bb8:	89 e5                	mov    %esp,%ebp
80103bba:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103bbd:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc7:	83 c0 0f             	add    $0xf,%eax
80103bca:	0f b6 00             	movzbl (%eax),%eax
80103bcd:	0f b6 c0             	movzbl %al,%eax
80103bd0:	c1 e0 08             	shl    $0x8,%eax
80103bd3:	89 c2                	mov    %eax,%edx
80103bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd8:	83 c0 0e             	add    $0xe,%eax
80103bdb:	0f b6 00             	movzbl (%eax),%eax
80103bde:	0f b6 c0             	movzbl %al,%eax
80103be1:	09 d0                	or     %edx,%eax
80103be3:	c1 e0 04             	shl    $0x4,%eax
80103be6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103be9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bed:	74 21                	je     80103c10 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103bef:	83 ec 08             	sub    $0x8,%esp
80103bf2:	68 00 04 00 00       	push   $0x400
80103bf7:	ff 75 f0             	push   -0x10(%ebp)
80103bfa:	e8 4c ff ff ff       	call   80103b4b <mpsearch1>
80103bff:	83 c4 10             	add    $0x10,%esp
80103c02:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c05:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c09:	74 51                	je     80103c5c <mpsearch+0xa5>
      return mp;
80103c0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c0e:	eb 61                	jmp    80103c71 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c13:	83 c0 14             	add    $0x14,%eax
80103c16:	0f b6 00             	movzbl (%eax),%eax
80103c19:	0f b6 c0             	movzbl %al,%eax
80103c1c:	c1 e0 08             	shl    $0x8,%eax
80103c1f:	89 c2                	mov    %eax,%edx
80103c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c24:	83 c0 13             	add    $0x13,%eax
80103c27:	0f b6 00             	movzbl (%eax),%eax
80103c2a:	0f b6 c0             	movzbl %al,%eax
80103c2d:	09 d0                	or     %edx,%eax
80103c2f:	c1 e0 0a             	shl    $0xa,%eax
80103c32:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c38:	2d 00 04 00 00       	sub    $0x400,%eax
80103c3d:	83 ec 08             	sub    $0x8,%esp
80103c40:	68 00 04 00 00       	push   $0x400
80103c45:	50                   	push   %eax
80103c46:	e8 00 ff ff ff       	call   80103b4b <mpsearch1>
80103c4b:	83 c4 10             	add    $0x10,%esp
80103c4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c51:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c55:	74 05                	je     80103c5c <mpsearch+0xa5>
      return mp;
80103c57:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c5a:	eb 15                	jmp    80103c71 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c5c:	83 ec 08             	sub    $0x8,%esp
80103c5f:	68 00 00 01 00       	push   $0x10000
80103c64:	68 00 00 0f 00       	push   $0xf0000
80103c69:	e8 dd fe ff ff       	call   80103b4b <mpsearch1>
80103c6e:	83 c4 10             	add    $0x10,%esp
}
80103c71:	c9                   	leave
80103c72:	c3                   	ret

80103c73 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c73:	55                   	push   %ebp
80103c74:	89 e5                	mov    %esp,%ebp
80103c76:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c79:	e8 39 ff ff ff       	call   80103bb7 <mpsearch>
80103c7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c85:	74 0a                	je     80103c91 <mpconfig+0x1e>
80103c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c8a:	8b 40 04             	mov    0x4(%eax),%eax
80103c8d:	85 c0                	test   %eax,%eax
80103c8f:	75 0a                	jne    80103c9b <mpconfig+0x28>
    return 0;
80103c91:	b8 00 00 00 00       	mov    $0x0,%eax
80103c96:	e9 81 00 00 00       	jmp    80103d1c <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9e:	8b 40 04             	mov    0x4(%eax),%eax
80103ca1:	83 ec 0c             	sub    $0xc,%esp
80103ca4:	50                   	push   %eax
80103ca5:	e8 08 fe ff ff       	call   80103ab2 <p2v>
80103caa:	83 c4 10             	add    $0x10,%esp
80103cad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103cb0:	83 ec 04             	sub    $0x4,%esp
80103cb3:	6a 04                	push   $0x4
80103cb5:	68 a1 88 10 80       	push   $0x801088a1
80103cba:	ff 75 f0             	push   -0x10(%ebp)
80103cbd:	e8 6b 16 00 00       	call   8010532d <memcmp>
80103cc2:	83 c4 10             	add    $0x10,%esp
80103cc5:	85 c0                	test   %eax,%eax
80103cc7:	74 07                	je     80103cd0 <mpconfig+0x5d>
    return 0;
80103cc9:	b8 00 00 00 00       	mov    $0x0,%eax
80103cce:	eb 4c                	jmp    80103d1c <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103cd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cd3:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cd7:	3c 01                	cmp    $0x1,%al
80103cd9:	74 12                	je     80103ced <mpconfig+0x7a>
80103cdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cde:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103ce2:	3c 04                	cmp    $0x4,%al
80103ce4:	74 07                	je     80103ced <mpconfig+0x7a>
    return 0;
80103ce6:	b8 00 00 00 00       	mov    $0x0,%eax
80103ceb:	eb 2f                	jmp    80103d1c <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf0:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cf4:	0f b7 c0             	movzwl %ax,%eax
80103cf7:	83 ec 08             	sub    $0x8,%esp
80103cfa:	50                   	push   %eax
80103cfb:	ff 75 f0             	push   -0x10(%ebp)
80103cfe:	e8 10 fe ff ff       	call   80103b13 <sum>
80103d03:	83 c4 10             	add    $0x10,%esp
80103d06:	84 c0                	test   %al,%al
80103d08:	74 07                	je     80103d11 <mpconfig+0x9e>
    return 0;
80103d0a:	b8 00 00 00 00       	mov    $0x0,%eax
80103d0f:	eb 0b                	jmp    80103d1c <mpconfig+0xa9>
  *pmp = mp;
80103d11:	8b 45 08             	mov    0x8(%ebp),%eax
80103d14:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d17:	89 10                	mov    %edx,(%eax)
  return conf;
80103d19:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d1c:	c9                   	leave
80103d1d:	c3                   	ret

80103d1e <mpinit>:

void
mpinit(void)
{
80103d1e:	55                   	push   %ebp
80103d1f:	89 e5                	mov    %esp,%ebp
80103d21:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103d24:	c7 05 0c 19 11 80 20 	movl   $0x80111320,0x8011190c
80103d2b:	13 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103d2e:	83 ec 0c             	sub    $0xc,%esp
80103d31:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103d34:	50                   	push   %eax
80103d35:	e8 39 ff ff ff       	call   80103c73 <mpconfig>
80103d3a:	83 c4 10             	add    $0x10,%esp
80103d3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d44:	0f 84 ba 01 00 00    	je     80103f04 <mpinit+0x1e6>
    return;
  ismp = 1;
80103d4a:	c7 05 00 19 11 80 01 	movl   $0x1,0x80111900
80103d51:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103d54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d57:	8b 40 24             	mov    0x24(%eax),%eax
80103d5a:	a3 20 12 11 80       	mov    %eax,0x80111220
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d62:	83 c0 2c             	add    $0x2c,%eax
80103d65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d6b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d6f:	0f b7 d0             	movzwl %ax,%edx
80103d72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d75:	01 d0                	add    %edx,%eax
80103d77:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d7a:	e9 16 01 00 00       	jmp    80103e95 <mpinit+0x177>
    switch(*p){
80103d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d82:	0f b6 00             	movzbl (%eax),%eax
80103d85:	0f b6 c0             	movzbl %al,%eax
80103d88:	83 f8 04             	cmp    $0x4,%eax
80103d8b:	0f 8f e0 00 00 00    	jg     80103e71 <mpinit+0x153>
80103d91:	83 f8 03             	cmp    $0x3,%eax
80103d94:	0f 8d d1 00 00 00    	jge    80103e6b <mpinit+0x14d>
80103d9a:	83 f8 02             	cmp    $0x2,%eax
80103d9d:	0f 84 b0 00 00 00    	je     80103e53 <mpinit+0x135>
80103da3:	83 f8 02             	cmp    $0x2,%eax
80103da6:	0f 8f c5 00 00 00    	jg     80103e71 <mpinit+0x153>
80103dac:	85 c0                	test   %eax,%eax
80103dae:	74 0e                	je     80103dbe <mpinit+0xa0>
80103db0:	83 f8 01             	cmp    $0x1,%eax
80103db3:	0f 84 b2 00 00 00    	je     80103e6b <mpinit+0x14d>
80103db9:	e9 b3 00 00 00       	jmp    80103e71 <mpinit+0x153>
    case MPPROC:
      proc = (struct mpproc*)p;
80103dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu != proc->apicid){
80103dc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103dc7:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103dcb:	0f b6 d0             	movzbl %al,%edx
80103dce:	a1 04 19 11 80       	mov    0x80111904,%eax
80103dd3:	39 c2                	cmp    %eax,%edx
80103dd5:	74 2b                	je     80103e02 <mpinit+0xe4>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103dd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103dda:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103dde:	0f b6 d0             	movzbl %al,%edx
80103de1:	a1 04 19 11 80       	mov    0x80111904,%eax
80103de6:	83 ec 04             	sub    $0x4,%esp
80103de9:	52                   	push   %edx
80103dea:	50                   	push   %eax
80103deb:	68 a6 88 10 80       	push   $0x801088a6
80103df0:	e8 cf c5 ff ff       	call   801003c4 <cprintf>
80103df5:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103df8:	c7 05 00 19 11 80 00 	movl   $0x0,0x80111900
80103dff:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103e02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103e05:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103e09:	0f b6 c0             	movzbl %al,%eax
80103e0c:	83 e0 02             	and    $0x2,%eax
80103e0f:	85 c0                	test   %eax,%eax
80103e11:	74 15                	je     80103e28 <mpinit+0x10a>
        bcpu = &cpus[ncpu];
80103e13:	a1 04 19 11 80       	mov    0x80111904,%eax
80103e18:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e1e:	05 20 13 11 80       	add    $0x80111320,%eax
80103e23:	a3 0c 19 11 80       	mov    %eax,0x8011190c
      cpus[ncpu].id = ncpu;
80103e28:	8b 15 04 19 11 80    	mov    0x80111904,%edx
80103e2e:	a1 04 19 11 80       	mov    0x80111904,%eax
80103e33:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e39:	05 20 13 11 80       	add    $0x80111320,%eax
80103e3e:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103e40:	a1 04 19 11 80       	mov    0x80111904,%eax
80103e45:	83 c0 01             	add    $0x1,%eax
80103e48:	a3 04 19 11 80       	mov    %eax,0x80111904
      p += sizeof(struct mpproc);
80103e4d:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103e51:	eb 42                	jmp    80103e95 <mpinit+0x177>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e56:	89 45 e8             	mov    %eax,-0x18(%ebp)
      ioapicid = ioapic->apicno;
80103e59:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e5c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e60:	a2 08 19 11 80       	mov    %al,0x80111908
      p += sizeof(struct mpioapic);
80103e65:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e69:	eb 2a                	jmp    80103e95 <mpinit+0x177>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e6b:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e6f:	eb 24                	jmp    80103e95 <mpinit+0x177>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e74:	0f b6 00             	movzbl (%eax),%eax
80103e77:	0f b6 c0             	movzbl %al,%eax
80103e7a:	83 ec 08             	sub    $0x8,%esp
80103e7d:	50                   	push   %eax
80103e7e:	68 c4 88 10 80       	push   $0x801088c4
80103e83:	e8 3c c5 ff ff       	call   801003c4 <cprintf>
80103e88:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103e8b:	c7 05 00 19 11 80 00 	movl   $0x0,0x80111900
80103e92:	00 00 00 
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e98:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e9b:	0f 82 de fe ff ff    	jb     80103d7f <mpinit+0x61>
    }
  }
  if(!ismp){
80103ea1:	a1 00 19 11 80       	mov    0x80111900,%eax
80103ea6:	85 c0                	test   %eax,%eax
80103ea8:	75 1d                	jne    80103ec7 <mpinit+0x1a9>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103eaa:	c7 05 04 19 11 80 01 	movl   $0x1,0x80111904
80103eb1:	00 00 00 
    lapic = 0;
80103eb4:	c7 05 20 12 11 80 00 	movl   $0x0,0x80111220
80103ebb:	00 00 00 
    ioapicid = 0;
80103ebe:	c6 05 08 19 11 80 00 	movb   $0x0,0x80111908
    return;
80103ec5:	eb 3e                	jmp    80103f05 <mpinit+0x1e7>
  }

  if(mp->imcrp){
80103ec7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103eca:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103ece:	84 c0                	test   %al,%al
80103ed0:	74 33                	je     80103f05 <mpinit+0x1e7>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103ed2:	83 ec 08             	sub    $0x8,%esp
80103ed5:	6a 70                	push   $0x70
80103ed7:	6a 22                	push   $0x22
80103ed9:	e8 fe fb ff ff       	call   80103adc <outb>
80103ede:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103ee1:	83 ec 0c             	sub    $0xc,%esp
80103ee4:	6a 23                	push   $0x23
80103ee6:	e8 d4 fb ff ff       	call   80103abf <inb>
80103eeb:	83 c4 10             	add    $0x10,%esp
80103eee:	83 c8 01             	or     $0x1,%eax
80103ef1:	0f b6 c0             	movzbl %al,%eax
80103ef4:	83 ec 08             	sub    $0x8,%esp
80103ef7:	50                   	push   %eax
80103ef8:	6a 23                	push   $0x23
80103efa:	e8 dd fb ff ff       	call   80103adc <outb>
80103eff:	83 c4 10             	add    $0x10,%esp
80103f02:	eb 01                	jmp    80103f05 <mpinit+0x1e7>
    return;
80103f04:	90                   	nop
  }
}
80103f05:	c9                   	leave
80103f06:	c3                   	ret

80103f07 <outb>:
{
80103f07:	55                   	push   %ebp
80103f08:	89 e5                	mov    %esp,%ebp
80103f0a:	83 ec 08             	sub    $0x8,%esp
80103f0d:	8b 55 08             	mov    0x8(%ebp),%edx
80103f10:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f13:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103f17:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103f1a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103f1e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103f22:	ee                   	out    %al,(%dx)
}
80103f23:	90                   	nop
80103f24:	c9                   	leave
80103f25:	c3                   	ret

80103f26 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103f26:	55                   	push   %ebp
80103f27:	89 e5                	mov    %esp,%ebp
80103f29:	83 ec 04             	sub    $0x4,%esp
80103f2c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f2f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103f33:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f37:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103f3d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f41:	0f b6 c0             	movzbl %al,%eax
80103f44:	50                   	push   %eax
80103f45:	6a 21                	push   $0x21
80103f47:	e8 bb ff ff ff       	call   80103f07 <outb>
80103f4c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103f4f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f53:	66 c1 e8 08          	shr    $0x8,%ax
80103f57:	0f b6 c0             	movzbl %al,%eax
80103f5a:	50                   	push   %eax
80103f5b:	68 a1 00 00 00       	push   $0xa1
80103f60:	e8 a2 ff ff ff       	call   80103f07 <outb>
80103f65:	83 c4 08             	add    $0x8,%esp
}
80103f68:	90                   	nop
80103f69:	c9                   	leave
80103f6a:	c3                   	ret

80103f6b <picenable>:

void
picenable(int irq)
{
80103f6b:	55                   	push   %ebp
80103f6c:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103f6e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f71:	ba 01 00 00 00       	mov    $0x1,%edx
80103f76:	89 c1                	mov    %eax,%ecx
80103f78:	d3 e2                	shl    %cl,%edx
80103f7a:	89 d0                	mov    %edx,%eax
80103f7c:	f7 d0                	not    %eax
80103f7e:	89 c2                	mov    %eax,%edx
80103f80:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f87:	21 d0                	and    %edx,%eax
80103f89:	0f b7 c0             	movzwl %ax,%eax
80103f8c:	50                   	push   %eax
80103f8d:	e8 94 ff ff ff       	call   80103f26 <picsetmask>
80103f92:	83 c4 04             	add    $0x4,%esp
}
80103f95:	90                   	nop
80103f96:	c9                   	leave
80103f97:	c3                   	ret

80103f98 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103f98:	55                   	push   %ebp
80103f99:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103f9b:	68 ff 00 00 00       	push   $0xff
80103fa0:	6a 21                	push   $0x21
80103fa2:	e8 60 ff ff ff       	call   80103f07 <outb>
80103fa7:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103faa:	68 ff 00 00 00       	push   $0xff
80103faf:	68 a1 00 00 00       	push   $0xa1
80103fb4:	e8 4e ff ff ff       	call   80103f07 <outb>
80103fb9:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103fbc:	6a 11                	push   $0x11
80103fbe:	6a 20                	push   $0x20
80103fc0:	e8 42 ff ff ff       	call   80103f07 <outb>
80103fc5:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103fc8:	6a 20                	push   $0x20
80103fca:	6a 21                	push   $0x21
80103fcc:	e8 36 ff ff ff       	call   80103f07 <outb>
80103fd1:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103fd4:	6a 04                	push   $0x4
80103fd6:	6a 21                	push   $0x21
80103fd8:	e8 2a ff ff ff       	call   80103f07 <outb>
80103fdd:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103fe0:	6a 03                	push   $0x3
80103fe2:	6a 21                	push   $0x21
80103fe4:	e8 1e ff ff ff       	call   80103f07 <outb>
80103fe9:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103fec:	6a 11                	push   $0x11
80103fee:	68 a0 00 00 00       	push   $0xa0
80103ff3:	e8 0f ff ff ff       	call   80103f07 <outb>
80103ff8:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103ffb:	6a 28                	push   $0x28
80103ffd:	68 a1 00 00 00       	push   $0xa1
80104002:	e8 00 ff ff ff       	call   80103f07 <outb>
80104007:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
8010400a:	6a 02                	push   $0x2
8010400c:	68 a1 00 00 00       	push   $0xa1
80104011:	e8 f1 fe ff ff       	call   80103f07 <outb>
80104016:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104019:	6a 03                	push   $0x3
8010401b:	68 a1 00 00 00       	push   $0xa1
80104020:	e8 e2 fe ff ff       	call   80103f07 <outb>
80104025:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104028:	6a 68                	push   $0x68
8010402a:	6a 20                	push   $0x20
8010402c:	e8 d6 fe ff ff       	call   80103f07 <outb>
80104031:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104034:	6a 0a                	push   $0xa
80104036:	6a 20                	push   $0x20
80104038:	e8 ca fe ff ff       	call   80103f07 <outb>
8010403d:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104040:	6a 68                	push   $0x68
80104042:	68 a0 00 00 00       	push   $0xa0
80104047:	e8 bb fe ff ff       	call   80103f07 <outb>
8010404c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
8010404f:	6a 0a                	push   $0xa
80104051:	68 a0 00 00 00       	push   $0xa0
80104056:	e8 ac fe ff ff       	call   80103f07 <outb>
8010405b:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
8010405e:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80104065:	66 83 f8 ff          	cmp    $0xffff,%ax
80104069:	74 13                	je     8010407e <picinit+0xe6>
    picsetmask(irqmask);
8010406b:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80104072:	0f b7 c0             	movzwl %ax,%eax
80104075:	50                   	push   %eax
80104076:	e8 ab fe ff ff       	call   80103f26 <picsetmask>
8010407b:	83 c4 04             	add    $0x4,%esp
}
8010407e:	90                   	nop
8010407f:	c9                   	leave
80104080:	c3                   	ret

80104081 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104081:	55                   	push   %ebp
80104082:	89 e5                	mov    %esp,%ebp
80104084:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104087:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010408e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104091:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104097:	8b 45 0c             	mov    0xc(%ebp),%eax
8010409a:	8b 10                	mov    (%eax),%edx
8010409c:	8b 45 08             	mov    0x8(%ebp),%eax
8010409f:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801040a1:	e8 1e cf ff ff       	call   80100fc4 <filealloc>
801040a6:	8b 55 08             	mov    0x8(%ebp),%edx
801040a9:	89 02                	mov    %eax,(%edx)
801040ab:	8b 45 08             	mov    0x8(%ebp),%eax
801040ae:	8b 00                	mov    (%eax),%eax
801040b0:	85 c0                	test   %eax,%eax
801040b2:	0f 84 c8 00 00 00    	je     80104180 <pipealloc+0xff>
801040b8:	e8 07 cf ff ff       	call   80100fc4 <filealloc>
801040bd:	8b 55 0c             	mov    0xc(%ebp),%edx
801040c0:	89 02                	mov    %eax,(%edx)
801040c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801040c5:	8b 00                	mov    (%eax),%eax
801040c7:	85 c0                	test   %eax,%eax
801040c9:	0f 84 b1 00 00 00    	je     80104180 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801040cf:	e8 a5 eb ff ff       	call   80102c79 <kalloc>
801040d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801040d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040db:	0f 84 a2 00 00 00    	je     80104183 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801040e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e4:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801040eb:	00 00 00 
  p->writeopen = 1;
801040ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f1:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801040f8:	00 00 00 
  p->nwrite = 0;
801040fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040fe:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104105:	00 00 00 
  p->nread = 0;
80104108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010410b:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104112:	00 00 00 
  initlock(&p->lock, "pipe");
80104115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104118:	83 ec 08             	sub    $0x8,%esp
8010411b:	68 e4 88 10 80       	push   $0x801088e4
80104120:	50                   	push   %eax
80104121:	e8 1a 0f 00 00       	call   80105040 <initlock>
80104126:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104129:	8b 45 08             	mov    0x8(%ebp),%eax
8010412c:	8b 00                	mov    (%eax),%eax
8010412e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104134:	8b 45 08             	mov    0x8(%ebp),%eax
80104137:	8b 00                	mov    (%eax),%eax
80104139:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010413d:	8b 45 08             	mov    0x8(%ebp),%eax
80104140:	8b 00                	mov    (%eax),%eax
80104142:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104146:	8b 45 08             	mov    0x8(%ebp),%eax
80104149:	8b 00                	mov    (%eax),%eax
8010414b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010414e:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104151:	8b 45 0c             	mov    0xc(%ebp),%eax
80104154:	8b 00                	mov    (%eax),%eax
80104156:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010415c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010415f:	8b 00                	mov    (%eax),%eax
80104161:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104165:	8b 45 0c             	mov    0xc(%ebp),%eax
80104168:	8b 00                	mov    (%eax),%eax
8010416a:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010416e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104171:	8b 00                	mov    (%eax),%eax
80104173:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104176:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104179:	b8 00 00 00 00       	mov    $0x0,%eax
8010417e:	eb 51                	jmp    801041d1 <pipealloc+0x150>
    goto bad;
80104180:	90                   	nop
80104181:	eb 01                	jmp    80104184 <pipealloc+0x103>
    goto bad;
80104183:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80104184:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104188:	74 0e                	je     80104198 <pipealloc+0x117>
    kfree((char*)p);
8010418a:	83 ec 0c             	sub    $0xc,%esp
8010418d:	ff 75 f4             	push   -0xc(%ebp)
80104190:	e8 47 ea ff ff       	call   80102bdc <kfree>
80104195:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104198:	8b 45 08             	mov    0x8(%ebp),%eax
8010419b:	8b 00                	mov    (%eax),%eax
8010419d:	85 c0                	test   %eax,%eax
8010419f:	74 11                	je     801041b2 <pipealloc+0x131>
    fileclose(*f0);
801041a1:	8b 45 08             	mov    0x8(%ebp),%eax
801041a4:	8b 00                	mov    (%eax),%eax
801041a6:	83 ec 0c             	sub    $0xc,%esp
801041a9:	50                   	push   %eax
801041aa:	e8 d3 ce ff ff       	call   80101082 <fileclose>
801041af:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801041b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801041b5:	8b 00                	mov    (%eax),%eax
801041b7:	85 c0                	test   %eax,%eax
801041b9:	74 11                	je     801041cc <pipealloc+0x14b>
    fileclose(*f1);
801041bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801041be:	8b 00                	mov    (%eax),%eax
801041c0:	83 ec 0c             	sub    $0xc,%esp
801041c3:	50                   	push   %eax
801041c4:	e8 b9 ce ff ff       	call   80101082 <fileclose>
801041c9:	83 c4 10             	add    $0x10,%esp
  return -1;
801041cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801041d1:	c9                   	leave
801041d2:	c3                   	ret

801041d3 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801041d3:	55                   	push   %ebp
801041d4:	89 e5                	mov    %esp,%ebp
801041d6:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801041d9:	8b 45 08             	mov    0x8(%ebp),%eax
801041dc:	83 ec 0c             	sub    $0xc,%esp
801041df:	50                   	push   %eax
801041e0:	e8 7d 0e 00 00       	call   80105062 <acquire>
801041e5:	83 c4 10             	add    $0x10,%esp
  if(writable){
801041e8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801041ec:	74 23                	je     80104211 <pipeclose+0x3e>
    p->writeopen = 0;
801041ee:	8b 45 08             	mov    0x8(%ebp),%eax
801041f1:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801041f8:	00 00 00 
    wakeup(&p->nread);
801041fb:	8b 45 08             	mov    0x8(%ebp),%eax
801041fe:	05 34 02 00 00       	add    $0x234,%eax
80104203:	83 ec 0c             	sub    $0xc,%esp
80104206:	50                   	push   %eax
80104207:	e8 47 0c 00 00       	call   80104e53 <wakeup>
8010420c:	83 c4 10             	add    $0x10,%esp
8010420f:	eb 21                	jmp    80104232 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104211:	8b 45 08             	mov    0x8(%ebp),%eax
80104214:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010421b:	00 00 00 
    wakeup(&p->nwrite);
8010421e:	8b 45 08             	mov    0x8(%ebp),%eax
80104221:	05 38 02 00 00       	add    $0x238,%eax
80104226:	83 ec 0c             	sub    $0xc,%esp
80104229:	50                   	push   %eax
8010422a:	e8 24 0c 00 00       	call   80104e53 <wakeup>
8010422f:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104232:	8b 45 08             	mov    0x8(%ebp),%eax
80104235:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010423b:	85 c0                	test   %eax,%eax
8010423d:	75 2c                	jne    8010426b <pipeclose+0x98>
8010423f:	8b 45 08             	mov    0x8(%ebp),%eax
80104242:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104248:	85 c0                	test   %eax,%eax
8010424a:	75 1f                	jne    8010426b <pipeclose+0x98>
    release(&p->lock);
8010424c:	8b 45 08             	mov    0x8(%ebp),%eax
8010424f:	83 ec 0c             	sub    $0xc,%esp
80104252:	50                   	push   %eax
80104253:	e8 71 0e 00 00       	call   801050c9 <release>
80104258:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010425b:	83 ec 0c             	sub    $0xc,%esp
8010425e:	ff 75 08             	push   0x8(%ebp)
80104261:	e8 76 e9 ff ff       	call   80102bdc <kfree>
80104266:	83 c4 10             	add    $0x10,%esp
80104269:	eb 10                	jmp    8010427b <pipeclose+0xa8>
  } else
    release(&p->lock);
8010426b:	8b 45 08             	mov    0x8(%ebp),%eax
8010426e:	83 ec 0c             	sub    $0xc,%esp
80104271:	50                   	push   %eax
80104272:	e8 52 0e 00 00       	call   801050c9 <release>
80104277:	83 c4 10             	add    $0x10,%esp
}
8010427a:	90                   	nop
8010427b:	90                   	nop
8010427c:	c9                   	leave
8010427d:	c3                   	ret

8010427e <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010427e:	55                   	push   %ebp
8010427f:	89 e5                	mov    %esp,%ebp
80104281:	53                   	push   %ebx
80104282:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104285:	8b 45 08             	mov    0x8(%ebp),%eax
80104288:	83 ec 0c             	sub    $0xc,%esp
8010428b:	50                   	push   %eax
8010428c:	e8 d1 0d 00 00       	call   80105062 <acquire>
80104291:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104294:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010429b:	e9 ae 00 00 00       	jmp    8010434e <pipewrite+0xd0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
801042a0:	8b 45 08             	mov    0x8(%ebp),%eax
801042a3:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801042a9:	85 c0                	test   %eax,%eax
801042ab:	74 0d                	je     801042ba <pipewrite+0x3c>
801042ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042b3:	8b 40 24             	mov    0x24(%eax),%eax
801042b6:	85 c0                	test   %eax,%eax
801042b8:	74 19                	je     801042d3 <pipewrite+0x55>
        release(&p->lock);
801042ba:	8b 45 08             	mov    0x8(%ebp),%eax
801042bd:	83 ec 0c             	sub    $0xc,%esp
801042c0:	50                   	push   %eax
801042c1:	e8 03 0e 00 00       	call   801050c9 <release>
801042c6:	83 c4 10             	add    $0x10,%esp
        return -1;
801042c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042ce:	e9 a9 00 00 00       	jmp    8010437c <pipewrite+0xfe>
      }
      wakeup(&p->nread);
801042d3:	8b 45 08             	mov    0x8(%ebp),%eax
801042d6:	05 34 02 00 00       	add    $0x234,%eax
801042db:	83 ec 0c             	sub    $0xc,%esp
801042de:	50                   	push   %eax
801042df:	e8 6f 0b 00 00       	call   80104e53 <wakeup>
801042e4:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042e7:	8b 45 08             	mov    0x8(%ebp),%eax
801042ea:	8b 55 08             	mov    0x8(%ebp),%edx
801042ed:	81 c2 38 02 00 00    	add    $0x238,%edx
801042f3:	83 ec 08             	sub    $0x8,%esp
801042f6:	50                   	push   %eax
801042f7:	52                   	push   %edx
801042f8:	e8 6a 0a 00 00       	call   80104d67 <sleep>
801042fd:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104300:	8b 45 08             	mov    0x8(%ebp),%eax
80104303:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104309:	8b 45 08             	mov    0x8(%ebp),%eax
8010430c:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104312:	05 00 02 00 00       	add    $0x200,%eax
80104317:	39 c2                	cmp    %eax,%edx
80104319:	74 85                	je     801042a0 <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010431b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010431e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104321:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104324:	8b 45 08             	mov    0x8(%ebp),%eax
80104327:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010432d:	8d 48 01             	lea    0x1(%eax),%ecx
80104330:	8b 55 08             	mov    0x8(%ebp),%edx
80104333:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104339:	25 ff 01 00 00       	and    $0x1ff,%eax
8010433e:	89 c1                	mov    %eax,%ecx
80104340:	0f b6 13             	movzbl (%ebx),%edx
80104343:	8b 45 08             	mov    0x8(%ebp),%eax
80104346:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
8010434a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010434e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104351:	3b 45 10             	cmp    0x10(%ebp),%eax
80104354:	7c aa                	jl     80104300 <pipewrite+0x82>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104356:	8b 45 08             	mov    0x8(%ebp),%eax
80104359:	05 34 02 00 00       	add    $0x234,%eax
8010435e:	83 ec 0c             	sub    $0xc,%esp
80104361:	50                   	push   %eax
80104362:	e8 ec 0a 00 00       	call   80104e53 <wakeup>
80104367:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010436a:	8b 45 08             	mov    0x8(%ebp),%eax
8010436d:	83 ec 0c             	sub    $0xc,%esp
80104370:	50                   	push   %eax
80104371:	e8 53 0d 00 00       	call   801050c9 <release>
80104376:	83 c4 10             	add    $0x10,%esp
  return n;
80104379:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010437c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010437f:	c9                   	leave
80104380:	c3                   	ret

80104381 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104381:	55                   	push   %ebp
80104382:	89 e5                	mov    %esp,%ebp
80104384:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104387:	8b 45 08             	mov    0x8(%ebp),%eax
8010438a:	83 ec 0c             	sub    $0xc,%esp
8010438d:	50                   	push   %eax
8010438e:	e8 cf 0c 00 00       	call   80105062 <acquire>
80104393:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104396:	eb 3f                	jmp    801043d7 <piperead+0x56>
    if(proc->killed){
80104398:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010439e:	8b 40 24             	mov    0x24(%eax),%eax
801043a1:	85 c0                	test   %eax,%eax
801043a3:	74 19                	je     801043be <piperead+0x3d>
      release(&p->lock);
801043a5:	8b 45 08             	mov    0x8(%ebp),%eax
801043a8:	83 ec 0c             	sub    $0xc,%esp
801043ab:	50                   	push   %eax
801043ac:	e8 18 0d 00 00       	call   801050c9 <release>
801043b1:	83 c4 10             	add    $0x10,%esp
      return -1;
801043b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043b9:	e9 be 00 00 00       	jmp    8010447c <piperead+0xfb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801043be:	8b 45 08             	mov    0x8(%ebp),%eax
801043c1:	8b 55 08             	mov    0x8(%ebp),%edx
801043c4:	81 c2 34 02 00 00    	add    $0x234,%edx
801043ca:	83 ec 08             	sub    $0x8,%esp
801043cd:	50                   	push   %eax
801043ce:	52                   	push   %edx
801043cf:	e8 93 09 00 00       	call   80104d67 <sleep>
801043d4:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801043d7:	8b 45 08             	mov    0x8(%ebp),%eax
801043da:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043e0:	8b 45 08             	mov    0x8(%ebp),%eax
801043e3:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043e9:	39 c2                	cmp    %eax,%edx
801043eb:	75 0d                	jne    801043fa <piperead+0x79>
801043ed:	8b 45 08             	mov    0x8(%ebp),%eax
801043f0:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043f6:	85 c0                	test   %eax,%eax
801043f8:	75 9e                	jne    80104398 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104401:	eb 48                	jmp    8010444b <piperead+0xca>
    if(p->nread == p->nwrite)
80104403:	8b 45 08             	mov    0x8(%ebp),%eax
80104406:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010440c:	8b 45 08             	mov    0x8(%ebp),%eax
8010440f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104415:	39 c2                	cmp    %eax,%edx
80104417:	74 3c                	je     80104455 <piperead+0xd4>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104419:	8b 45 08             	mov    0x8(%ebp),%eax
8010441c:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104422:	8d 48 01             	lea    0x1(%eax),%ecx
80104425:	8b 55 08             	mov    0x8(%ebp),%edx
80104428:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010442e:	25 ff 01 00 00       	and    $0x1ff,%eax
80104433:	89 c1                	mov    %eax,%ecx
80104435:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104438:	8b 45 0c             	mov    0xc(%ebp),%eax
8010443b:	01 c2                	add    %eax,%edx
8010443d:	8b 45 08             	mov    0x8(%ebp),%eax
80104440:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80104445:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104447:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010444b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444e:	3b 45 10             	cmp    0x10(%ebp),%eax
80104451:	7c b0                	jl     80104403 <piperead+0x82>
80104453:	eb 01                	jmp    80104456 <piperead+0xd5>
      break;
80104455:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104456:	8b 45 08             	mov    0x8(%ebp),%eax
80104459:	05 38 02 00 00       	add    $0x238,%eax
8010445e:	83 ec 0c             	sub    $0xc,%esp
80104461:	50                   	push   %eax
80104462:	e8 ec 09 00 00       	call   80104e53 <wakeup>
80104467:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010446a:	8b 45 08             	mov    0x8(%ebp),%eax
8010446d:	83 ec 0c             	sub    $0xc,%esp
80104470:	50                   	push   %eax
80104471:	e8 53 0c 00 00       	call   801050c9 <release>
80104476:	83 c4 10             	add    $0x10,%esp
  return i;
80104479:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010447c:	c9                   	leave
8010447d:	c3                   	ret

8010447e <readeflags>:
{
8010447e:	55                   	push   %ebp
8010447f:	89 e5                	mov    %esp,%ebp
80104481:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104484:	9c                   	pushf
80104485:	58                   	pop    %eax
80104486:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104489:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010448c:	c9                   	leave
8010448d:	c3                   	ret

8010448e <sti>:
{
8010448e:	55                   	push   %ebp
8010448f:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104491:	fb                   	sti
}
80104492:	90                   	nop
80104493:	5d                   	pop    %ebp
80104494:	c3                   	ret

80104495 <halt>:
}

// CS550: to solve the 100%-CPU-utilization-when-idling problem - "hlt" instruction puts CPU to sleep
static inline void
halt()
{
80104495:	55                   	push   %ebp
80104496:	89 e5                	mov    %esp,%ebp
    asm volatile("hlt" : : :"memory");
80104498:	f4                   	hlt
}
80104499:	90                   	nop
8010449a:	5d                   	pop    %ebp
8010449b:	c3                   	ret

8010449c <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010449c:	55                   	push   %ebp
8010449d:	89 e5                	mov    %esp,%ebp
8010449f:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
801044a2:	83 ec 08             	sub    $0x8,%esp
801044a5:	68 e9 88 10 80       	push   $0x801088e9
801044aa:	68 20 19 11 80       	push   $0x80111920
801044af:	e8 8c 0b 00 00       	call   80105040 <initlock>
801044b4:	83 c4 10             	add    $0x10,%esp
}
801044b7:	90                   	nop
801044b8:	c9                   	leave
801044b9:	c3                   	ret

801044ba <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801044ba:	55                   	push   %ebp
801044bb:	89 e5                	mov    %esp,%ebp
801044bd:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801044c0:	83 ec 0c             	sub    $0xc,%esp
801044c3:	68 20 19 11 80       	push   $0x80111920
801044c8:	e8 95 0b 00 00       	call   80105062 <acquire>
801044cd:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044d0:	c7 45 f4 54 19 11 80 	movl   $0x80111954,-0xc(%ebp)
801044d7:	eb 0e                	jmp    801044e7 <allocproc+0x2d>
    if(p->state == UNUSED)
801044d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044dc:	8b 40 0c             	mov    0xc(%eax),%eax
801044df:	85 c0                	test   %eax,%eax
801044e1:	74 27                	je     8010450a <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044e3:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801044e7:	81 7d f4 54 38 11 80 	cmpl   $0x80113854,-0xc(%ebp)
801044ee:	72 e9                	jb     801044d9 <allocproc+0x1f>
      goto found;
  release(&ptable.lock);
801044f0:	83 ec 0c             	sub    $0xc,%esp
801044f3:	68 20 19 11 80       	push   $0x80111920
801044f8:	e8 cc 0b 00 00       	call   801050c9 <release>
801044fd:	83 c4 10             	add    $0x10,%esp
  return 0;
80104500:	b8 00 00 00 00       	mov    $0x0,%eax
80104505:	e9 b2 00 00 00       	jmp    801045bc <allocproc+0x102>
      goto found;
8010450a:	90                   	nop

found:
  p->state = EMBRYO;
8010450b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450e:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104515:	a1 04 b0 10 80       	mov    0x8010b004,%eax
8010451a:	8d 50 01             	lea    0x1(%eax),%edx
8010451d:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
80104523:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104526:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104529:	83 ec 0c             	sub    $0xc,%esp
8010452c:	68 20 19 11 80       	push   $0x80111920
80104531:	e8 93 0b 00 00       	call   801050c9 <release>
80104536:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104539:	e8 3b e7 ff ff       	call   80102c79 <kalloc>
8010453e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104541:	89 42 08             	mov    %eax,0x8(%edx)
80104544:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104547:	8b 40 08             	mov    0x8(%eax),%eax
8010454a:	85 c0                	test   %eax,%eax
8010454c:	75 11                	jne    8010455f <allocproc+0xa5>
    p->state = UNUSED;
8010454e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104551:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104558:	b8 00 00 00 00       	mov    $0x0,%eax
8010455d:	eb 5d                	jmp    801045bc <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
8010455f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104562:	8b 40 08             	mov    0x8(%eax),%eax
80104565:	05 00 10 00 00       	add    $0x1000,%eax
8010456a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010456d:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104571:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104574:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104577:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010457a:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010457e:	ba a1 66 10 80       	mov    $0x801066a1,%edx
80104583:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104586:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104588:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010458c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104592:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104595:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104598:	8b 40 1c             	mov    0x1c(%eax),%eax
8010459b:	83 ec 04             	sub    $0x4,%esp
8010459e:	6a 14                	push   $0x14
801045a0:	6a 00                	push   $0x0
801045a2:	50                   	push   %eax
801045a3:	e8 1e 0d 00 00       	call   801052c6 <memset>
801045a8:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801045ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ae:	8b 40 1c             	mov    0x1c(%eax),%eax
801045b1:	ba 21 4d 10 80       	mov    $0x80104d21,%edx
801045b6:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801045b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801045bc:	c9                   	leave
801045bd:	c3                   	ret

801045be <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801045be:	55                   	push   %ebp
801045bf:	89 e5                	mov    %esp,%ebp
801045c1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801045c4:	e8 f1 fe ff ff       	call   801044ba <allocproc>
801045c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801045cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045cf:	a3 54 38 11 80       	mov    %eax,0x80113854
  if((p->pgdir = setupkvm()) == 0)
801045d4:	e8 8e 37 00 00       	call   80107d67 <setupkvm>
801045d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045dc:	89 42 04             	mov    %eax,0x4(%edx)
801045df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e2:	8b 40 04             	mov    0x4(%eax),%eax
801045e5:	85 c0                	test   %eax,%eax
801045e7:	75 0d                	jne    801045f6 <userinit+0x38>
    panic("userinit: out of memory?");
801045e9:	83 ec 0c             	sub    $0xc,%esp
801045ec:	68 f0 88 10 80       	push   $0x801088f0
801045f1:	e8 83 bf ff ff       	call   80100579 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801045f6:	ba 2c 00 00 00       	mov    $0x2c,%edx
801045fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fe:	8b 40 04             	mov    0x4(%eax),%eax
80104601:	83 ec 04             	sub    $0x4,%esp
80104604:	52                   	push   %edx
80104605:	68 e0 b4 10 80       	push   $0x8010b4e0
8010460a:	50                   	push   %eax
8010460b:	e8 b2 39 00 00       	call   80107fc2 <inituvm>
80104610:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104616:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010461c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461f:	8b 40 18             	mov    0x18(%eax),%eax
80104622:	83 ec 04             	sub    $0x4,%esp
80104625:	6a 4c                	push   $0x4c
80104627:	6a 00                	push   $0x0
80104629:	50                   	push   %eax
8010462a:	e8 97 0c 00 00       	call   801052c6 <memset>
8010462f:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104632:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104635:	8b 40 18             	mov    0x18(%eax),%eax
80104638:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010463e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104641:	8b 40 18             	mov    0x18(%eax),%eax
80104644:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010464a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464d:	8b 50 18             	mov    0x18(%eax),%edx
80104650:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104653:	8b 40 18             	mov    0x18(%eax),%eax
80104656:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010465a:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010465e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104661:	8b 50 18             	mov    0x18(%eax),%edx
80104664:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104667:	8b 40 18             	mov    0x18(%eax),%eax
8010466a:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010466e:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104675:	8b 40 18             	mov    0x18(%eax),%eax
80104678:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010467f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104682:	8b 40 18             	mov    0x18(%eax),%eax
80104685:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010468c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468f:	8b 40 18             	mov    0x18(%eax),%eax
80104692:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104699:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010469c:	83 c0 6c             	add    $0x6c,%eax
8010469f:	83 ec 04             	sub    $0x4,%esp
801046a2:	6a 10                	push   $0x10
801046a4:	68 09 89 10 80       	push   $0x80108909
801046a9:	50                   	push   %eax
801046aa:	e8 1a 0e 00 00       	call   801054c9 <safestrcpy>
801046af:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801046b2:	83 ec 0c             	sub    $0xc,%esp
801046b5:	68 12 89 10 80       	push   $0x80108912
801046ba:	e8 7b de ff ff       	call   8010253a <namei>
801046bf:	83 c4 10             	add    $0x10,%esp
801046c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046c5:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
801046c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046cb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801046d2:	90                   	nop
801046d3:	c9                   	leave
801046d4:	c3                   	ret

801046d5 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801046d5:	55                   	push   %ebp
801046d6:	89 e5                	mov    %esp,%ebp
801046d8:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801046db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e1:	8b 00                	mov    (%eax),%eax
801046e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801046e6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046ea:	7e 31                	jle    8010471d <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801046ec:	8b 55 08             	mov    0x8(%ebp),%edx
801046ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f2:	01 c2                	add    %eax,%edx
801046f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046fa:	8b 40 04             	mov    0x4(%eax),%eax
801046fd:	83 ec 04             	sub    $0x4,%esp
80104700:	52                   	push   %edx
80104701:	ff 75 f4             	push   -0xc(%ebp)
80104704:	50                   	push   %eax
80104705:	e8 05 3a 00 00       	call   8010810f <allocuvm>
8010470a:	83 c4 10             	add    $0x10,%esp
8010470d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104710:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104714:	75 3e                	jne    80104754 <growproc+0x7f>
      return -1;
80104716:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010471b:	eb 59                	jmp    80104776 <growproc+0xa1>
  } else if(n < 0){
8010471d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104721:	79 31                	jns    80104754 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104723:	8b 55 08             	mov    0x8(%ebp),%edx
80104726:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104729:	01 c2                	add    %eax,%edx
8010472b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104731:	8b 40 04             	mov    0x4(%eax),%eax
80104734:	83 ec 04             	sub    $0x4,%esp
80104737:	52                   	push   %edx
80104738:	ff 75 f4             	push   -0xc(%ebp)
8010473b:	50                   	push   %eax
8010473c:	e8 95 3a 00 00       	call   801081d6 <deallocuvm>
80104741:	83 c4 10             	add    $0x10,%esp
80104744:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104747:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010474b:	75 07                	jne    80104754 <growproc+0x7f>
      return -1;
8010474d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104752:	eb 22                	jmp    80104776 <growproc+0xa1>
  }
  proc->sz = sz;
80104754:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010475a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010475d:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010475f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104765:	83 ec 0c             	sub    $0xc,%esp
80104768:	50                   	push   %eax
80104769:	e8 e0 36 00 00       	call   80107e4e <switchuvm>
8010476e:	83 c4 10             	add    $0x10,%esp
  return 0;
80104771:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104776:	c9                   	leave
80104777:	c3                   	ret

80104778 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104778:	55                   	push   %ebp
80104779:	89 e5                	mov    %esp,%ebp
8010477b:	57                   	push   %edi
8010477c:	56                   	push   %esi
8010477d:	53                   	push   %ebx
8010477e:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104781:	e8 34 fd ff ff       	call   801044ba <allocproc>
80104786:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104789:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010478d:	75 0a                	jne    80104799 <fork+0x21>
    return -1;
8010478f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104794:	e9 64 01 00 00       	jmp    801048fd <fork+0x185>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104799:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010479f:	8b 10                	mov    (%eax),%edx
801047a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047a7:	8b 40 04             	mov    0x4(%eax),%eax
801047aa:	83 ec 08             	sub    $0x8,%esp
801047ad:	52                   	push   %edx
801047ae:	50                   	push   %eax
801047af:	e8 c0 3b 00 00       	call   80108374 <copyuvm>
801047b4:	83 c4 10             	add    $0x10,%esp
801047b7:	8b 55 e0             	mov    -0x20(%ebp),%edx
801047ba:	89 42 04             	mov    %eax,0x4(%edx)
801047bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047c0:	8b 40 04             	mov    0x4(%eax),%eax
801047c3:	85 c0                	test   %eax,%eax
801047c5:	75 30                	jne    801047f7 <fork+0x7f>
    kfree(np->kstack);
801047c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ca:	8b 40 08             	mov    0x8(%eax),%eax
801047cd:	83 ec 0c             	sub    $0xc,%esp
801047d0:	50                   	push   %eax
801047d1:	e8 06 e4 ff ff       	call   80102bdc <kfree>
801047d6:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801047d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047dc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801047e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047e6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801047ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047f2:	e9 06 01 00 00       	jmp    801048fd <fork+0x185>
  }
  np->sz = proc->sz;
801047f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047fd:	8b 10                	mov    (%eax),%edx
801047ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104802:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104804:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010480b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010480e:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104811:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104817:	8b 48 18             	mov    0x18(%eax),%ecx
8010481a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010481d:	8b 40 18             	mov    0x18(%eax),%eax
80104820:	89 c2                	mov    %eax,%edx
80104822:	89 cb                	mov    %ecx,%ebx
80104824:	b8 13 00 00 00       	mov    $0x13,%eax
80104829:	89 d7                	mov    %edx,%edi
8010482b:	89 de                	mov    %ebx,%esi
8010482d:	89 c1                	mov    %eax,%ecx
8010482f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104831:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104834:	8b 40 18             	mov    0x18(%eax),%eax
80104837:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010483e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104845:	eb 41                	jmp    80104888 <fork+0x110>
    if(proc->ofile[i])
80104847:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010484d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104850:	83 c2 08             	add    $0x8,%edx
80104853:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104857:	85 c0                	test   %eax,%eax
80104859:	74 29                	je     80104884 <fork+0x10c>
      np->ofile[i] = filedup(proc->ofile[i]);
8010485b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104861:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104864:	83 c2 08             	add    $0x8,%edx
80104867:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010486b:	83 ec 0c             	sub    $0xc,%esp
8010486e:	50                   	push   %eax
8010486f:	e8 bd c7 ff ff       	call   80101031 <filedup>
80104874:	83 c4 10             	add    $0x10,%esp
80104877:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010487a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010487d:	83 c1 08             	add    $0x8,%ecx
80104880:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104884:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104888:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010488c:	7e b9                	jle    80104847 <fork+0xcf>
  np->cwd = idup(proc->cwd);
8010488e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104894:	8b 40 68             	mov    0x68(%eax),%eax
80104897:	83 ec 0c             	sub    $0xc,%esp
8010489a:	50                   	push   %eax
8010489b:	e8 af d0 ff ff       	call   8010194f <idup>
801048a0:	83 c4 10             	add    $0x10,%esp
801048a3:	8b 55 e0             	mov    -0x20(%ebp),%edx
801048a6:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801048a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048af:	8d 50 6c             	lea    0x6c(%eax),%edx
801048b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048b5:	83 c0 6c             	add    $0x6c,%eax
801048b8:	83 ec 04             	sub    $0x4,%esp
801048bb:	6a 10                	push   $0x10
801048bd:	52                   	push   %edx
801048be:	50                   	push   %eax
801048bf:	e8 05 0c 00 00       	call   801054c9 <safestrcpy>
801048c4:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801048c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048ca:	8b 40 10             	mov    0x10(%eax),%eax
801048cd:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801048d0:	83 ec 0c             	sub    $0xc,%esp
801048d3:	68 20 19 11 80       	push   $0x80111920
801048d8:	e8 85 07 00 00       	call   80105062 <acquire>
801048dd:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801048e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048e3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801048ea:	83 ec 0c             	sub    $0xc,%esp
801048ed:	68 20 19 11 80       	push   $0x80111920
801048f2:	e8 d2 07 00 00       	call   801050c9 <release>
801048f7:	83 c4 10             	add    $0x10,%esp
  
  return pid;
801048fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801048fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104900:	5b                   	pop    %ebx
80104901:	5e                   	pop    %esi
80104902:	5f                   	pop    %edi
80104903:	5d                   	pop    %ebp
80104904:	c3                   	ret

80104905 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104905:	55                   	push   %ebp
80104906:	89 e5                	mov    %esp,%ebp
80104908:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
8010490b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104912:	a1 54 38 11 80       	mov    0x80113854,%eax
80104917:	39 c2                	cmp    %eax,%edx
80104919:	75 0d                	jne    80104928 <exit+0x23>
    panic("init exiting");
8010491b:	83 ec 0c             	sub    $0xc,%esp
8010491e:	68 14 89 10 80       	push   $0x80108914
80104923:	e8 51 bc ff ff       	call   80100579 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104928:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010492f:	eb 48                	jmp    80104979 <exit+0x74>
    if(proc->ofile[fd]){
80104931:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104937:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010493a:	83 c2 08             	add    $0x8,%edx
8010493d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104941:	85 c0                	test   %eax,%eax
80104943:	74 30                	je     80104975 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104945:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010494b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010494e:	83 c2 08             	add    $0x8,%edx
80104951:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104955:	83 ec 0c             	sub    $0xc,%esp
80104958:	50                   	push   %eax
80104959:	e8 24 c7 ff ff       	call   80101082 <fileclose>
8010495e:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104961:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104967:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010496a:	83 c2 08             	add    $0x8,%edx
8010496d:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104974:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104975:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104979:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010497d:	7e b2                	jle    80104931 <exit+0x2c>
    }
  }

  begin_op();
8010497f:	e8 d2 eb ff ff       	call   80103556 <begin_op>
  iput(proc->cwd);
80104984:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010498a:	8b 40 68             	mov    0x68(%eax),%eax
8010498d:	83 ec 0c             	sub    $0xc,%esp
80104990:	50                   	push   %eax
80104991:	e8 c3 d1 ff ff       	call   80101b59 <iput>
80104996:	83 c4 10             	add    $0x10,%esp
  end_op();
80104999:	e8 44 ec ff ff       	call   801035e2 <end_op>
  proc->cwd = 0;
8010499e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049a4:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801049ab:	83 ec 0c             	sub    $0xc,%esp
801049ae:	68 20 19 11 80       	push   $0x80111920
801049b3:	e8 aa 06 00 00       	call   80105062 <acquire>
801049b8:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801049bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049c1:	8b 40 14             	mov    0x14(%eax),%eax
801049c4:	83 ec 0c             	sub    $0xc,%esp
801049c7:	50                   	push   %eax
801049c8:	e8 46 04 00 00       	call   80104e13 <wakeup1>
801049cd:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049d0:	c7 45 f4 54 19 11 80 	movl   $0x80111954,-0xc(%ebp)
801049d7:	eb 3c                	jmp    80104a15 <exit+0x110>
    if(p->parent == proc){
801049d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049dc:	8b 50 14             	mov    0x14(%eax),%edx
801049df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049e5:	39 c2                	cmp    %eax,%edx
801049e7:	75 28                	jne    80104a11 <exit+0x10c>
      p->parent = initproc;
801049e9:	8b 15 54 38 11 80    	mov    0x80113854,%edx
801049ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f2:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801049f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f8:	8b 40 0c             	mov    0xc(%eax),%eax
801049fb:	83 f8 05             	cmp    $0x5,%eax
801049fe:	75 11                	jne    80104a11 <exit+0x10c>
        wakeup1(initproc);
80104a00:	a1 54 38 11 80       	mov    0x80113854,%eax
80104a05:	83 ec 0c             	sub    $0xc,%esp
80104a08:	50                   	push   %eax
80104a09:	e8 05 04 00 00       	call   80104e13 <wakeup1>
80104a0e:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a11:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104a15:	81 7d f4 54 38 11 80 	cmpl   $0x80113854,-0xc(%ebp)
80104a1c:	72 bb                	jb     801049d9 <exit+0xd4>
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104a1e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a24:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104a2b:	e8 fa 01 00 00       	call   80104c2a <sched>
  panic("zombie exit");
80104a30:	83 ec 0c             	sub    $0xc,%esp
80104a33:	68 21 89 10 80       	push   $0x80108921
80104a38:	e8 3c bb ff ff       	call   80100579 <panic>

80104a3d <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a3d:	55                   	push   %ebp
80104a3e:	89 e5                	mov    %esp,%ebp
80104a40:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a43:	83 ec 0c             	sub    $0xc,%esp
80104a46:	68 20 19 11 80       	push   $0x80111920
80104a4b:	e8 12 06 00 00       	call   80105062 <acquire>
80104a50:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a53:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a5a:	c7 45 f4 54 19 11 80 	movl   $0x80111954,-0xc(%ebp)
80104a61:	e9 a6 00 00 00       	jmp    80104b0c <wait+0xcf>
      if(p->parent != proc)
80104a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a69:	8b 50 14             	mov    0x14(%eax),%edx
80104a6c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a72:	39 c2                	cmp    %eax,%edx
80104a74:	0f 85 8d 00 00 00    	jne    80104b07 <wait+0xca>
        continue;
      havekids = 1;
80104a7a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a84:	8b 40 0c             	mov    0xc(%eax),%eax
80104a87:	83 f8 05             	cmp    $0x5,%eax
80104a8a:	75 7c                	jne    80104b08 <wait+0xcb>
        // Found one.
        pid = p->pid;
80104a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8f:	8b 40 10             	mov    0x10(%eax),%eax
80104a92:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a98:	8b 40 08             	mov    0x8(%eax),%eax
80104a9b:	83 ec 0c             	sub    $0xc,%esp
80104a9e:	50                   	push   %eax
80104a9f:	e8 38 e1 ff ff       	call   80102bdc <kfree>
80104aa4:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aaa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab4:	8b 40 04             	mov    0x4(%eax),%eax
80104ab7:	83 ec 0c             	sub    $0xc,%esp
80104aba:	50                   	push   %eax
80104abb:	e8 d3 37 00 00       	call   80108293 <freevm>
80104ac0:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad0:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ada:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae4:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aeb:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104af2:	83 ec 0c             	sub    $0xc,%esp
80104af5:	68 20 19 11 80       	push   $0x80111920
80104afa:	e8 ca 05 00 00       	call   801050c9 <release>
80104aff:	83 c4 10             	add    $0x10,%esp
        return pid;
80104b02:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b05:	eb 58                	jmp    80104b5f <wait+0x122>
        continue;
80104b07:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b08:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104b0c:	81 7d f4 54 38 11 80 	cmpl   $0x80113854,-0xc(%ebp)
80104b13:	0f 82 4d ff ff ff    	jb     80104a66 <wait+0x29>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b19:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b1d:	74 0d                	je     80104b2c <wait+0xef>
80104b1f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b25:	8b 40 24             	mov    0x24(%eax),%eax
80104b28:	85 c0                	test   %eax,%eax
80104b2a:	74 17                	je     80104b43 <wait+0x106>
      release(&ptable.lock);
80104b2c:	83 ec 0c             	sub    $0xc,%esp
80104b2f:	68 20 19 11 80       	push   $0x80111920
80104b34:	e8 90 05 00 00       	call   801050c9 <release>
80104b39:	83 c4 10             	add    $0x10,%esp
      return -1;
80104b3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b41:	eb 1c                	jmp    80104b5f <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b43:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b49:	83 ec 08             	sub    $0x8,%esp
80104b4c:	68 20 19 11 80       	push   $0x80111920
80104b51:	50                   	push   %eax
80104b52:	e8 10 02 00 00       	call   80104d67 <sleep>
80104b57:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104b5a:	e9 f4 fe ff ff       	jmp    80104a53 <wait+0x16>
  }
}
80104b5f:	c9                   	leave
80104b60:	c3                   	ret

80104b61 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b61:	55                   	push   %ebp
80104b62:	89 e5                	mov    %esp,%ebp
80104b64:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int ran = 0; // CS550: to solve the 100%-CPU-utilization-when-idling problem
80104b67:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b6e:	e8 1b f9 ff ff       	call   8010448e <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104b73:	83 ec 0c             	sub    $0xc,%esp
80104b76:	68 20 19 11 80       	push   $0x80111920
80104b7b:	e8 e2 04 00 00       	call   80105062 <acquire>
80104b80:	83 c4 10             	add    $0x10,%esp
    ran = 0;
80104b83:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b8a:	c7 45 f4 54 19 11 80 	movl   $0x80111954,-0xc(%ebp)
80104b91:	eb 6a                	jmp    80104bfd <scheduler+0x9c>
      if(p->state != RUNNABLE)
80104b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b96:	8b 40 0c             	mov    0xc(%eax),%eax
80104b99:	83 f8 03             	cmp    $0x3,%eax
80104b9c:	75 5a                	jne    80104bf8 <scheduler+0x97>
        continue;

      ran = 1;
80104b9e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba8:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104bae:	83 ec 0c             	sub    $0xc,%esp
80104bb1:	ff 75 f4             	push   -0xc(%ebp)
80104bb4:	e8 95 32 00 00       	call   80107e4e <switchuvm>
80104bb9:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bbf:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104bc6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bcc:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bcf:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104bd6:	83 c2 04             	add    $0x4,%edx
80104bd9:	83 ec 08             	sub    $0x8,%esp
80104bdc:	50                   	push   %eax
80104bdd:	52                   	push   %edx
80104bde:	e8 58 09 00 00       	call   8010553b <swtch>
80104be3:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104be6:	e8 46 32 00 00       	call   80107e31 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104beb:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104bf2:	00 00 00 00 
80104bf6:	eb 01                	jmp    80104bf9 <scheduler+0x98>
        continue;
80104bf8:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bf9:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104bfd:	81 7d f4 54 38 11 80 	cmpl   $0x80113854,-0xc(%ebp)
80104c04:	72 8d                	jb     80104b93 <scheduler+0x32>
    }
    release(&ptable.lock);
80104c06:	83 ec 0c             	sub    $0xc,%esp
80104c09:	68 20 19 11 80       	push   $0x80111920
80104c0e:	e8 b6 04 00 00       	call   801050c9 <release>
80104c13:	83 c4 10             	add    $0x10,%esp

    if (ran == 0){
80104c16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c1a:	0f 85 4e ff ff ff    	jne    80104b6e <scheduler+0xd>
        halt();
80104c20:	e8 70 f8 ff ff       	call   80104495 <halt>
    sti();
80104c25:	e9 44 ff ff ff       	jmp    80104b6e <scheduler+0xd>

80104c2a <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104c2a:	55                   	push   %ebp
80104c2b:	89 e5                	mov    %esp,%ebp
80104c2d:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104c30:	83 ec 0c             	sub    $0xc,%esp
80104c33:	68 20 19 11 80       	push   $0x80111920
80104c38:	e8 59 05 00 00       	call   80105196 <holding>
80104c3d:	83 c4 10             	add    $0x10,%esp
80104c40:	85 c0                	test   %eax,%eax
80104c42:	75 0d                	jne    80104c51 <sched+0x27>
    panic("sched ptable.lock");
80104c44:	83 ec 0c             	sub    $0xc,%esp
80104c47:	68 2d 89 10 80       	push   $0x8010892d
80104c4c:	e8 28 b9 ff ff       	call   80100579 <panic>
  if(cpu->ncli != 1)
80104c51:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c57:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104c5d:	83 f8 01             	cmp    $0x1,%eax
80104c60:	74 0d                	je     80104c6f <sched+0x45>
    panic("sched locks");
80104c62:	83 ec 0c             	sub    $0xc,%esp
80104c65:	68 3f 89 10 80       	push   $0x8010893f
80104c6a:	e8 0a b9 ff ff       	call   80100579 <panic>
  if(proc->state == RUNNING)
80104c6f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c75:	8b 40 0c             	mov    0xc(%eax),%eax
80104c78:	83 f8 04             	cmp    $0x4,%eax
80104c7b:	75 0d                	jne    80104c8a <sched+0x60>
    panic("sched running");
80104c7d:	83 ec 0c             	sub    $0xc,%esp
80104c80:	68 4b 89 10 80       	push   $0x8010894b
80104c85:	e8 ef b8 ff ff       	call   80100579 <panic>
  if(readeflags()&FL_IF)
80104c8a:	e8 ef f7 ff ff       	call   8010447e <readeflags>
80104c8f:	25 00 02 00 00       	and    $0x200,%eax
80104c94:	85 c0                	test   %eax,%eax
80104c96:	74 0d                	je     80104ca5 <sched+0x7b>
    panic("sched interruptible");
80104c98:	83 ec 0c             	sub    $0xc,%esp
80104c9b:	68 59 89 10 80       	push   $0x80108959
80104ca0:	e8 d4 b8 ff ff       	call   80100579 <panic>
  intena = cpu->intena;
80104ca5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cab:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104cb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104cb4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cba:	8b 40 04             	mov    0x4(%eax),%eax
80104cbd:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104cc4:	83 c2 1c             	add    $0x1c,%edx
80104cc7:	83 ec 08             	sub    $0x8,%esp
80104cca:	50                   	push   %eax
80104ccb:	52                   	push   %edx
80104ccc:	e8 6a 08 00 00       	call   8010553b <swtch>
80104cd1:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104cd4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cda:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cdd:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104ce3:	90                   	nop
80104ce4:	c9                   	leave
80104ce5:	c3                   	ret

80104ce6 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104ce6:	55                   	push   %ebp
80104ce7:	89 e5                	mov    %esp,%ebp
80104ce9:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104cec:	83 ec 0c             	sub    $0xc,%esp
80104cef:	68 20 19 11 80       	push   $0x80111920
80104cf4:	e8 69 03 00 00       	call   80105062 <acquire>
80104cf9:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80104cfc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d02:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104d09:	e8 1c ff ff ff       	call   80104c2a <sched>
  release(&ptable.lock);
80104d0e:	83 ec 0c             	sub    $0xc,%esp
80104d11:	68 20 19 11 80       	push   $0x80111920
80104d16:	e8 ae 03 00 00       	call   801050c9 <release>
80104d1b:	83 c4 10             	add    $0x10,%esp
}
80104d1e:	90                   	nop
80104d1f:	c9                   	leave
80104d20:	c3                   	ret

80104d21 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104d21:	55                   	push   %ebp
80104d22:	89 e5                	mov    %esp,%ebp
80104d24:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104d27:	83 ec 0c             	sub    $0xc,%esp
80104d2a:	68 20 19 11 80       	push   $0x80111920
80104d2f:	e8 95 03 00 00       	call   801050c9 <release>
80104d34:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104d37:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104d3c:	85 c0                	test   %eax,%eax
80104d3e:	74 24                	je     80104d64 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104d40:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104d47:	00 00 00 
    iinit(ROOTDEV);
80104d4a:	83 ec 0c             	sub    $0xc,%esp
80104d4d:	6a 01                	push   $0x1
80104d4f:	e8 0a c9 ff ff       	call   8010165e <iinit>
80104d54:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104d57:	83 ec 0c             	sub    $0xc,%esp
80104d5a:	6a 01                	push   $0x1
80104d5c:	e8 d6 e5 ff ff       	call   80103337 <initlog>
80104d61:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104d64:	90                   	nop
80104d65:	c9                   	leave
80104d66:	c3                   	ret

80104d67 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104d67:	55                   	push   %ebp
80104d68:	89 e5                	mov    %esp,%ebp
80104d6a:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80104d6d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d73:	85 c0                	test   %eax,%eax
80104d75:	75 0d                	jne    80104d84 <sleep+0x1d>
    panic("sleep");
80104d77:	83 ec 0c             	sub    $0xc,%esp
80104d7a:	68 6d 89 10 80       	push   $0x8010896d
80104d7f:	e8 f5 b7 ff ff       	call   80100579 <panic>

  if(lk == 0)
80104d84:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104d88:	75 0d                	jne    80104d97 <sleep+0x30>
    panic("sleep without lk");
80104d8a:	83 ec 0c             	sub    $0xc,%esp
80104d8d:	68 73 89 10 80       	push   $0x80108973
80104d92:	e8 e2 b7 ff ff       	call   80100579 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104d97:	81 7d 0c 20 19 11 80 	cmpl   $0x80111920,0xc(%ebp)
80104d9e:	74 1e                	je     80104dbe <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104da0:	83 ec 0c             	sub    $0xc,%esp
80104da3:	68 20 19 11 80       	push   $0x80111920
80104da8:	e8 b5 02 00 00       	call   80105062 <acquire>
80104dad:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104db0:	83 ec 0c             	sub    $0xc,%esp
80104db3:	ff 75 0c             	push   0xc(%ebp)
80104db6:	e8 0e 03 00 00       	call   801050c9 <release>
80104dbb:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80104dbe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dc4:	8b 55 08             	mov    0x8(%ebp),%edx
80104dc7:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104dca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dd0:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104dd7:	e8 4e fe ff ff       	call   80104c2a <sched>

  // Tidy up.
  proc->chan = 0;
80104ddc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104de2:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104de9:	81 7d 0c 20 19 11 80 	cmpl   $0x80111920,0xc(%ebp)
80104df0:	74 1e                	je     80104e10 <sleep+0xa9>
    release(&ptable.lock);
80104df2:	83 ec 0c             	sub    $0xc,%esp
80104df5:	68 20 19 11 80       	push   $0x80111920
80104dfa:	e8 ca 02 00 00       	call   801050c9 <release>
80104dff:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104e02:	83 ec 0c             	sub    $0xc,%esp
80104e05:	ff 75 0c             	push   0xc(%ebp)
80104e08:	e8 55 02 00 00       	call   80105062 <acquire>
80104e0d:	83 c4 10             	add    $0x10,%esp
  }
}
80104e10:	90                   	nop
80104e11:	c9                   	leave
80104e12:	c3                   	ret

80104e13 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104e13:	55                   	push   %ebp
80104e14:	89 e5                	mov    %esp,%ebp
80104e16:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e19:	c7 45 fc 54 19 11 80 	movl   $0x80111954,-0x4(%ebp)
80104e20:	eb 24                	jmp    80104e46 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104e22:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e25:	8b 40 0c             	mov    0xc(%eax),%eax
80104e28:	83 f8 02             	cmp    $0x2,%eax
80104e2b:	75 15                	jne    80104e42 <wakeup1+0x2f>
80104e2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e30:	8b 40 20             	mov    0x20(%eax),%eax
80104e33:	39 45 08             	cmp    %eax,0x8(%ebp)
80104e36:	75 0a                	jne    80104e42 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104e38:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e3b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e42:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104e46:	81 7d fc 54 38 11 80 	cmpl   $0x80113854,-0x4(%ebp)
80104e4d:	72 d3                	jb     80104e22 <wakeup1+0xf>
}
80104e4f:	90                   	nop
80104e50:	90                   	nop
80104e51:	c9                   	leave
80104e52:	c3                   	ret

80104e53 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104e53:	55                   	push   %ebp
80104e54:	89 e5                	mov    %esp,%ebp
80104e56:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104e59:	83 ec 0c             	sub    $0xc,%esp
80104e5c:	68 20 19 11 80       	push   $0x80111920
80104e61:	e8 fc 01 00 00       	call   80105062 <acquire>
80104e66:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104e69:	83 ec 0c             	sub    $0xc,%esp
80104e6c:	ff 75 08             	push   0x8(%ebp)
80104e6f:	e8 9f ff ff ff       	call   80104e13 <wakeup1>
80104e74:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104e77:	83 ec 0c             	sub    $0xc,%esp
80104e7a:	68 20 19 11 80       	push   $0x80111920
80104e7f:	e8 45 02 00 00       	call   801050c9 <release>
80104e84:	83 c4 10             	add    $0x10,%esp
}
80104e87:	90                   	nop
80104e88:	c9                   	leave
80104e89:	c3                   	ret

80104e8a <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104e8a:	55                   	push   %ebp
80104e8b:	89 e5                	mov    %esp,%ebp
80104e8d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104e90:	83 ec 0c             	sub    $0xc,%esp
80104e93:	68 20 19 11 80       	push   $0x80111920
80104e98:	e8 c5 01 00 00       	call   80105062 <acquire>
80104e9d:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ea0:	c7 45 f4 54 19 11 80 	movl   $0x80111954,-0xc(%ebp)
80104ea7:	eb 45                	jmp    80104eee <kill+0x64>
    if(p->pid == pid){
80104ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eac:	8b 40 10             	mov    0x10(%eax),%eax
80104eaf:	39 45 08             	cmp    %eax,0x8(%ebp)
80104eb2:	75 36                	jne    80104eea <kill+0x60>
      p->killed = 1;
80104eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eb7:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec1:	8b 40 0c             	mov    0xc(%eax),%eax
80104ec4:	83 f8 02             	cmp    $0x2,%eax
80104ec7:	75 0a                	jne    80104ed3 <kill+0x49>
        p->state = RUNNABLE;
80104ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ecc:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104ed3:	83 ec 0c             	sub    $0xc,%esp
80104ed6:	68 20 19 11 80       	push   $0x80111920
80104edb:	e8 e9 01 00 00       	call   801050c9 <release>
80104ee0:	83 c4 10             	add    $0x10,%esp
      return 0;
80104ee3:	b8 00 00 00 00       	mov    $0x0,%eax
80104ee8:	eb 22                	jmp    80104f0c <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104eea:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104eee:	81 7d f4 54 38 11 80 	cmpl   $0x80113854,-0xc(%ebp)
80104ef5:	72 b2                	jb     80104ea9 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104ef7:	83 ec 0c             	sub    $0xc,%esp
80104efa:	68 20 19 11 80       	push   $0x80111920
80104eff:	e8 c5 01 00 00       	call   801050c9 <release>
80104f04:	83 c4 10             	add    $0x10,%esp
  return -1;
80104f07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f0c:	c9                   	leave
80104f0d:	c3                   	ret

80104f0e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104f0e:	55                   	push   %ebp
80104f0f:	89 e5                	mov    %esp,%ebp
80104f11:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f14:	c7 45 f0 54 19 11 80 	movl   $0x80111954,-0x10(%ebp)
80104f1b:	e9 d7 00 00 00       	jmp    80104ff7 <procdump+0xe9>
    if(p->state == UNUSED)
80104f20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f23:	8b 40 0c             	mov    0xc(%eax),%eax
80104f26:	85 c0                	test   %eax,%eax
80104f28:	0f 84 c4 00 00 00    	je     80104ff2 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f31:	8b 40 0c             	mov    0xc(%eax),%eax
80104f34:	83 f8 05             	cmp    $0x5,%eax
80104f37:	77 23                	ja     80104f5c <procdump+0x4e>
80104f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f3c:	8b 40 0c             	mov    0xc(%eax),%eax
80104f3f:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f46:	85 c0                	test   %eax,%eax
80104f48:	74 12                	je     80104f5c <procdump+0x4e>
      state = states[p->state];
80104f4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f4d:	8b 40 0c             	mov    0xc(%eax),%eax
80104f50:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f57:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104f5a:	eb 07                	jmp    80104f63 <procdump+0x55>
    else
      state = "???";
80104f5c:	c7 45 ec 84 89 10 80 	movl   $0x80108984,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104f63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f66:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f6c:	8b 40 10             	mov    0x10(%eax),%eax
80104f6f:	52                   	push   %edx
80104f70:	ff 75 ec             	push   -0x14(%ebp)
80104f73:	50                   	push   %eax
80104f74:	68 88 89 10 80       	push   $0x80108988
80104f79:	e8 46 b4 ff ff       	call   801003c4 <cprintf>
80104f7e:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104f81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f84:	8b 40 0c             	mov    0xc(%eax),%eax
80104f87:	83 f8 02             	cmp    $0x2,%eax
80104f8a:	75 54                	jne    80104fe0 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104f8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f8f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f92:	8b 40 0c             	mov    0xc(%eax),%eax
80104f95:	83 c0 08             	add    $0x8,%eax
80104f98:	89 c2                	mov    %eax,%edx
80104f9a:	83 ec 08             	sub    $0x8,%esp
80104f9d:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104fa0:	50                   	push   %eax
80104fa1:	52                   	push   %edx
80104fa2:	e8 74 01 00 00       	call   8010511b <getcallerpcs>
80104fa7:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104faa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104fb1:	eb 1c                	jmp    80104fcf <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fb6:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104fba:	83 ec 08             	sub    $0x8,%esp
80104fbd:	50                   	push   %eax
80104fbe:	68 91 89 10 80       	push   $0x80108991
80104fc3:	e8 fc b3 ff ff       	call   801003c4 <cprintf>
80104fc8:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104fcb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104fcf:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104fd3:	7f 0b                	jg     80104fe0 <procdump+0xd2>
80104fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd8:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104fdc:	85 c0                	test   %eax,%eax
80104fde:	75 d3                	jne    80104fb3 <procdump+0xa5>
    }
    cprintf("\n");
80104fe0:	83 ec 0c             	sub    $0xc,%esp
80104fe3:	68 95 89 10 80       	push   $0x80108995
80104fe8:	e8 d7 b3 ff ff       	call   801003c4 <cprintf>
80104fed:	83 c4 10             	add    $0x10,%esp
80104ff0:	eb 01                	jmp    80104ff3 <procdump+0xe5>
      continue;
80104ff2:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ff3:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104ff7:	81 7d f0 54 38 11 80 	cmpl   $0x80113854,-0x10(%ebp)
80104ffe:	0f 82 1c ff ff ff    	jb     80104f20 <procdump+0x12>
  }
}
80105004:	90                   	nop
80105005:	90                   	nop
80105006:	c9                   	leave
80105007:	c3                   	ret

80105008 <readeflags>:
{
80105008:	55                   	push   %ebp
80105009:	89 e5                	mov    %esp,%ebp
8010500b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010500e:	9c                   	pushf
8010500f:	58                   	pop    %eax
80105010:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105013:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105016:	c9                   	leave
80105017:	c3                   	ret

80105018 <cli>:
{
80105018:	55                   	push   %ebp
80105019:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010501b:	fa                   	cli
}
8010501c:	90                   	nop
8010501d:	5d                   	pop    %ebp
8010501e:	c3                   	ret

8010501f <sti>:
{
8010501f:	55                   	push   %ebp
80105020:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105022:	fb                   	sti
}
80105023:	90                   	nop
80105024:	5d                   	pop    %ebp
80105025:	c3                   	ret

80105026 <xchg>:
{
80105026:	55                   	push   %ebp
80105027:	89 e5                	mov    %esp,%ebp
80105029:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
8010502c:	8b 55 08             	mov    0x8(%ebp),%edx
8010502f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105032:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105035:	f0 87 02             	lock xchg %eax,(%edx)
80105038:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
8010503b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010503e:	c9                   	leave
8010503f:	c3                   	ret

80105040 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105040:	55                   	push   %ebp
80105041:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105043:	8b 45 08             	mov    0x8(%ebp),%eax
80105046:	8b 55 0c             	mov    0xc(%ebp),%edx
80105049:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010504c:	8b 45 08             	mov    0x8(%ebp),%eax
8010504f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105055:	8b 45 08             	mov    0x8(%ebp),%eax
80105058:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010505f:	90                   	nop
80105060:	5d                   	pop    %ebp
80105061:	c3                   	ret

80105062 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105062:	55                   	push   %ebp
80105063:	89 e5                	mov    %esp,%ebp
80105065:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105068:	e8 53 01 00 00       	call   801051c0 <pushcli>
  if(holding(lk))
8010506d:	8b 45 08             	mov    0x8(%ebp),%eax
80105070:	83 ec 0c             	sub    $0xc,%esp
80105073:	50                   	push   %eax
80105074:	e8 1d 01 00 00       	call   80105196 <holding>
80105079:	83 c4 10             	add    $0x10,%esp
8010507c:	85 c0                	test   %eax,%eax
8010507e:	74 0d                	je     8010508d <acquire+0x2b>
    panic("acquire");
80105080:	83 ec 0c             	sub    $0xc,%esp
80105083:	68 c1 89 10 80       	push   $0x801089c1
80105088:	e8 ec b4 ff ff       	call   80100579 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
8010508d:	90                   	nop
8010508e:	8b 45 08             	mov    0x8(%ebp),%eax
80105091:	83 ec 08             	sub    $0x8,%esp
80105094:	6a 01                	push   $0x1
80105096:	50                   	push   %eax
80105097:	e8 8a ff ff ff       	call   80105026 <xchg>
8010509c:	83 c4 10             	add    $0x10,%esp
8010509f:	85 c0                	test   %eax,%eax
801050a1:	75 eb                	jne    8010508e <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801050a3:	8b 45 08             	mov    0x8(%ebp),%eax
801050a6:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801050ad:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801050b0:	8b 45 08             	mov    0x8(%ebp),%eax
801050b3:	83 c0 0c             	add    $0xc,%eax
801050b6:	83 ec 08             	sub    $0x8,%esp
801050b9:	50                   	push   %eax
801050ba:	8d 45 08             	lea    0x8(%ebp),%eax
801050bd:	50                   	push   %eax
801050be:	e8 58 00 00 00       	call   8010511b <getcallerpcs>
801050c3:	83 c4 10             	add    $0x10,%esp
}
801050c6:	90                   	nop
801050c7:	c9                   	leave
801050c8:	c3                   	ret

801050c9 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801050c9:	55                   	push   %ebp
801050ca:	89 e5                	mov    %esp,%ebp
801050cc:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801050cf:	83 ec 0c             	sub    $0xc,%esp
801050d2:	ff 75 08             	push   0x8(%ebp)
801050d5:	e8 bc 00 00 00       	call   80105196 <holding>
801050da:	83 c4 10             	add    $0x10,%esp
801050dd:	85 c0                	test   %eax,%eax
801050df:	75 0d                	jne    801050ee <release+0x25>
    panic("release");
801050e1:	83 ec 0c             	sub    $0xc,%esp
801050e4:	68 c9 89 10 80       	push   $0x801089c9
801050e9:	e8 8b b4 ff ff       	call   80100579 <panic>

  lk->pcs[0] = 0;
801050ee:	8b 45 08             	mov    0x8(%ebp),%eax
801050f1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801050f8:	8b 45 08             	mov    0x8(%ebp),%eax
801050fb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105102:	8b 45 08             	mov    0x8(%ebp),%eax
80105105:	83 ec 08             	sub    $0x8,%esp
80105108:	6a 00                	push   $0x0
8010510a:	50                   	push   %eax
8010510b:	e8 16 ff ff ff       	call   80105026 <xchg>
80105110:	83 c4 10             	add    $0x10,%esp

  popcli();
80105113:	e8 ed 00 00 00       	call   80105205 <popcli>
}
80105118:	90                   	nop
80105119:	c9                   	leave
8010511a:	c3                   	ret

8010511b <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010511b:	55                   	push   %ebp
8010511c:	89 e5                	mov    %esp,%ebp
8010511e:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105121:	8b 45 08             	mov    0x8(%ebp),%eax
80105124:	83 e8 08             	sub    $0x8,%eax
80105127:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010512a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105131:	eb 38                	jmp    8010516b <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105133:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105137:	74 53                	je     8010518c <getcallerpcs+0x71>
80105139:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105140:	76 4a                	jbe    8010518c <getcallerpcs+0x71>
80105142:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105146:	74 44                	je     8010518c <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105148:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010514b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105152:	8b 45 0c             	mov    0xc(%ebp),%eax
80105155:	01 c2                	add    %eax,%edx
80105157:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010515a:	8b 40 04             	mov    0x4(%eax),%eax
8010515d:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010515f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105162:	8b 00                	mov    (%eax),%eax
80105164:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105167:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010516b:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010516f:	7e c2                	jle    80105133 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80105171:	eb 19                	jmp    8010518c <getcallerpcs+0x71>
    pcs[i] = 0;
80105173:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105176:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010517d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105180:	01 d0                	add    %edx,%eax
80105182:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80105188:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010518c:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105190:	7e e1                	jle    80105173 <getcallerpcs+0x58>
}
80105192:	90                   	nop
80105193:	90                   	nop
80105194:	c9                   	leave
80105195:	c3                   	ret

80105196 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105196:	55                   	push   %ebp
80105197:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105199:	8b 45 08             	mov    0x8(%ebp),%eax
8010519c:	8b 00                	mov    (%eax),%eax
8010519e:	85 c0                	test   %eax,%eax
801051a0:	74 17                	je     801051b9 <holding+0x23>
801051a2:	8b 45 08             	mov    0x8(%ebp),%eax
801051a5:	8b 50 08             	mov    0x8(%eax),%edx
801051a8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051ae:	39 c2                	cmp    %eax,%edx
801051b0:	75 07                	jne    801051b9 <holding+0x23>
801051b2:	b8 01 00 00 00       	mov    $0x1,%eax
801051b7:	eb 05                	jmp    801051be <holding+0x28>
801051b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051be:	5d                   	pop    %ebp
801051bf:	c3                   	ret

801051c0 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801051c0:	55                   	push   %ebp
801051c1:	89 e5                	mov    %esp,%ebp
801051c3:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801051c6:	e8 3d fe ff ff       	call   80105008 <readeflags>
801051cb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801051ce:	e8 45 fe ff ff       	call   80105018 <cli>
  if(cpu->ncli++ == 0)
801051d3:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801051da:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
801051e0:	8d 48 01             	lea    0x1(%eax),%ecx
801051e3:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
801051e9:	85 c0                	test   %eax,%eax
801051eb:	75 15                	jne    80105202 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
801051ed:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051f3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801051f6:	81 e2 00 02 00 00    	and    $0x200,%edx
801051fc:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105202:	90                   	nop
80105203:	c9                   	leave
80105204:	c3                   	ret

80105205 <popcli>:

void
popcli(void)
{
80105205:	55                   	push   %ebp
80105206:	89 e5                	mov    %esp,%ebp
80105208:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010520b:	e8 f8 fd ff ff       	call   80105008 <readeflags>
80105210:	25 00 02 00 00       	and    $0x200,%eax
80105215:	85 c0                	test   %eax,%eax
80105217:	74 0d                	je     80105226 <popcli+0x21>
    panic("popcli - interruptible");
80105219:	83 ec 0c             	sub    $0xc,%esp
8010521c:	68 d1 89 10 80       	push   $0x801089d1
80105221:	e8 53 b3 ff ff       	call   80100579 <panic>
  if(--cpu->ncli < 0)
80105226:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010522c:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105232:	83 ea 01             	sub    $0x1,%edx
80105235:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010523b:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105241:	85 c0                	test   %eax,%eax
80105243:	79 0d                	jns    80105252 <popcli+0x4d>
    panic("popcli");
80105245:	83 ec 0c             	sub    $0xc,%esp
80105248:	68 e8 89 10 80       	push   $0x801089e8
8010524d:	e8 27 b3 ff ff       	call   80100579 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105252:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105258:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010525e:	85 c0                	test   %eax,%eax
80105260:	75 15                	jne    80105277 <popcli+0x72>
80105262:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105268:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010526e:	85 c0                	test   %eax,%eax
80105270:	74 05                	je     80105277 <popcli+0x72>
    sti();
80105272:	e8 a8 fd ff ff       	call   8010501f <sti>
}
80105277:	90                   	nop
80105278:	c9                   	leave
80105279:	c3                   	ret

8010527a <stosb>:
{
8010527a:	55                   	push   %ebp
8010527b:	89 e5                	mov    %esp,%ebp
8010527d:	57                   	push   %edi
8010527e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010527f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105282:	8b 55 10             	mov    0x10(%ebp),%edx
80105285:	8b 45 0c             	mov    0xc(%ebp),%eax
80105288:	89 cb                	mov    %ecx,%ebx
8010528a:	89 df                	mov    %ebx,%edi
8010528c:	89 d1                	mov    %edx,%ecx
8010528e:	fc                   	cld
8010528f:	f3 aa                	rep stos %al,%es:(%edi)
80105291:	89 ca                	mov    %ecx,%edx
80105293:	89 fb                	mov    %edi,%ebx
80105295:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105298:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010529b:	90                   	nop
8010529c:	5b                   	pop    %ebx
8010529d:	5f                   	pop    %edi
8010529e:	5d                   	pop    %ebp
8010529f:	c3                   	ret

801052a0 <stosl>:
{
801052a0:	55                   	push   %ebp
801052a1:	89 e5                	mov    %esp,%ebp
801052a3:	57                   	push   %edi
801052a4:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801052a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052a8:	8b 55 10             	mov    0x10(%ebp),%edx
801052ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ae:	89 cb                	mov    %ecx,%ebx
801052b0:	89 df                	mov    %ebx,%edi
801052b2:	89 d1                	mov    %edx,%ecx
801052b4:	fc                   	cld
801052b5:	f3 ab                	rep stos %eax,%es:(%edi)
801052b7:	89 ca                	mov    %ecx,%edx
801052b9:	89 fb                	mov    %edi,%ebx
801052bb:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052be:	89 55 10             	mov    %edx,0x10(%ebp)
}
801052c1:	90                   	nop
801052c2:	5b                   	pop    %ebx
801052c3:	5f                   	pop    %edi
801052c4:	5d                   	pop    %ebp
801052c5:	c3                   	ret

801052c6 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801052c6:	55                   	push   %ebp
801052c7:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801052c9:	8b 45 08             	mov    0x8(%ebp),%eax
801052cc:	83 e0 03             	and    $0x3,%eax
801052cf:	85 c0                	test   %eax,%eax
801052d1:	75 43                	jne    80105316 <memset+0x50>
801052d3:	8b 45 10             	mov    0x10(%ebp),%eax
801052d6:	83 e0 03             	and    $0x3,%eax
801052d9:	85 c0                	test   %eax,%eax
801052db:	75 39                	jne    80105316 <memset+0x50>
    c &= 0xFF;
801052dd:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801052e4:	8b 45 10             	mov    0x10(%ebp),%eax
801052e7:	c1 e8 02             	shr    $0x2,%eax
801052ea:	89 c1                	mov    %eax,%ecx
801052ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ef:	c1 e0 18             	shl    $0x18,%eax
801052f2:	89 c2                	mov    %eax,%edx
801052f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801052f7:	c1 e0 10             	shl    $0x10,%eax
801052fa:	09 c2                	or     %eax,%edx
801052fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ff:	c1 e0 08             	shl    $0x8,%eax
80105302:	09 d0                	or     %edx,%eax
80105304:	0b 45 0c             	or     0xc(%ebp),%eax
80105307:	51                   	push   %ecx
80105308:	50                   	push   %eax
80105309:	ff 75 08             	push   0x8(%ebp)
8010530c:	e8 8f ff ff ff       	call   801052a0 <stosl>
80105311:	83 c4 0c             	add    $0xc,%esp
80105314:	eb 12                	jmp    80105328 <memset+0x62>
  } else
    stosb(dst, c, n);
80105316:	8b 45 10             	mov    0x10(%ebp),%eax
80105319:	50                   	push   %eax
8010531a:	ff 75 0c             	push   0xc(%ebp)
8010531d:	ff 75 08             	push   0x8(%ebp)
80105320:	e8 55 ff ff ff       	call   8010527a <stosb>
80105325:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105328:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010532b:	c9                   	leave
8010532c:	c3                   	ret

8010532d <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010532d:	55                   	push   %ebp
8010532e:	89 e5                	mov    %esp,%ebp
80105330:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105333:	8b 45 08             	mov    0x8(%ebp),%eax
80105336:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105339:	8b 45 0c             	mov    0xc(%ebp),%eax
8010533c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010533f:	eb 2e                	jmp    8010536f <memcmp+0x42>
    if(*s1 != *s2)
80105341:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105344:	0f b6 10             	movzbl (%eax),%edx
80105347:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010534a:	0f b6 00             	movzbl (%eax),%eax
8010534d:	38 c2                	cmp    %al,%dl
8010534f:	74 16                	je     80105367 <memcmp+0x3a>
      return *s1 - *s2;
80105351:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105354:	0f b6 00             	movzbl (%eax),%eax
80105357:	0f b6 d0             	movzbl %al,%edx
8010535a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010535d:	0f b6 00             	movzbl (%eax),%eax
80105360:	0f b6 c0             	movzbl %al,%eax
80105363:	29 c2                	sub    %eax,%edx
80105365:	eb 1a                	jmp    80105381 <memcmp+0x54>
    s1++, s2++;
80105367:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010536b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
8010536f:	8b 45 10             	mov    0x10(%ebp),%eax
80105372:	8d 50 ff             	lea    -0x1(%eax),%edx
80105375:	89 55 10             	mov    %edx,0x10(%ebp)
80105378:	85 c0                	test   %eax,%eax
8010537a:	75 c5                	jne    80105341 <memcmp+0x14>
  }

  return 0;
8010537c:	ba 00 00 00 00       	mov    $0x0,%edx
}
80105381:	89 d0                	mov    %edx,%eax
80105383:	c9                   	leave
80105384:	c3                   	ret

80105385 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105385:	55                   	push   %ebp
80105386:	89 e5                	mov    %esp,%ebp
80105388:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010538b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010538e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105391:	8b 45 08             	mov    0x8(%ebp),%eax
80105394:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105397:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010539a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010539d:	73 54                	jae    801053f3 <memmove+0x6e>
8010539f:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053a2:	8b 45 10             	mov    0x10(%ebp),%eax
801053a5:	01 d0                	add    %edx,%eax
801053a7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801053aa:	73 47                	jae    801053f3 <memmove+0x6e>
    s += n;
801053ac:	8b 45 10             	mov    0x10(%ebp),%eax
801053af:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801053b2:	8b 45 10             	mov    0x10(%ebp),%eax
801053b5:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801053b8:	eb 13                	jmp    801053cd <memmove+0x48>
      *--d = *--s;
801053ba:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801053be:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801053c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053c5:	0f b6 10             	movzbl (%eax),%edx
801053c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053cb:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801053cd:	8b 45 10             	mov    0x10(%ebp),%eax
801053d0:	8d 50 ff             	lea    -0x1(%eax),%edx
801053d3:	89 55 10             	mov    %edx,0x10(%ebp)
801053d6:	85 c0                	test   %eax,%eax
801053d8:	75 e0                	jne    801053ba <memmove+0x35>
  if(s < d && s + n > d){
801053da:	eb 24                	jmp    80105400 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
801053dc:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053df:	8d 42 01             	lea    0x1(%edx),%eax
801053e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
801053e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053e8:	8d 48 01             	lea    0x1(%eax),%ecx
801053eb:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801053ee:	0f b6 12             	movzbl (%edx),%edx
801053f1:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801053f3:	8b 45 10             	mov    0x10(%ebp),%eax
801053f6:	8d 50 ff             	lea    -0x1(%eax),%edx
801053f9:	89 55 10             	mov    %edx,0x10(%ebp)
801053fc:	85 c0                	test   %eax,%eax
801053fe:	75 dc                	jne    801053dc <memmove+0x57>

  return dst;
80105400:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105403:	c9                   	leave
80105404:	c3                   	ret

80105405 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105405:	55                   	push   %ebp
80105406:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105408:	ff 75 10             	push   0x10(%ebp)
8010540b:	ff 75 0c             	push   0xc(%ebp)
8010540e:	ff 75 08             	push   0x8(%ebp)
80105411:	e8 6f ff ff ff       	call   80105385 <memmove>
80105416:	83 c4 0c             	add    $0xc,%esp
}
80105419:	c9                   	leave
8010541a:	c3                   	ret

8010541b <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010541b:	55                   	push   %ebp
8010541c:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010541e:	eb 0c                	jmp    8010542c <strncmp+0x11>
    n--, p++, q++;
80105420:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105424:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105428:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
8010542c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105430:	74 1a                	je     8010544c <strncmp+0x31>
80105432:	8b 45 08             	mov    0x8(%ebp),%eax
80105435:	0f b6 00             	movzbl (%eax),%eax
80105438:	84 c0                	test   %al,%al
8010543a:	74 10                	je     8010544c <strncmp+0x31>
8010543c:	8b 45 08             	mov    0x8(%ebp),%eax
8010543f:	0f b6 10             	movzbl (%eax),%edx
80105442:	8b 45 0c             	mov    0xc(%ebp),%eax
80105445:	0f b6 00             	movzbl (%eax),%eax
80105448:	38 c2                	cmp    %al,%dl
8010544a:	74 d4                	je     80105420 <strncmp+0x5>
  if(n == 0)
8010544c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105450:	75 07                	jne    80105459 <strncmp+0x3e>
    return 0;
80105452:	ba 00 00 00 00       	mov    $0x0,%edx
80105457:	eb 14                	jmp    8010546d <strncmp+0x52>
  return (uchar)*p - (uchar)*q;
80105459:	8b 45 08             	mov    0x8(%ebp),%eax
8010545c:	0f b6 00             	movzbl (%eax),%eax
8010545f:	0f b6 d0             	movzbl %al,%edx
80105462:	8b 45 0c             	mov    0xc(%ebp),%eax
80105465:	0f b6 00             	movzbl (%eax),%eax
80105468:	0f b6 c0             	movzbl %al,%eax
8010546b:	29 c2                	sub    %eax,%edx
}
8010546d:	89 d0                	mov    %edx,%eax
8010546f:	5d                   	pop    %ebp
80105470:	c3                   	ret

80105471 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105471:	55                   	push   %ebp
80105472:	89 e5                	mov    %esp,%ebp
80105474:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105477:	8b 45 08             	mov    0x8(%ebp),%eax
8010547a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010547d:	90                   	nop
8010547e:	8b 45 10             	mov    0x10(%ebp),%eax
80105481:	8d 50 ff             	lea    -0x1(%eax),%edx
80105484:	89 55 10             	mov    %edx,0x10(%ebp)
80105487:	85 c0                	test   %eax,%eax
80105489:	7e 2c                	jle    801054b7 <strncpy+0x46>
8010548b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010548e:	8d 42 01             	lea    0x1(%edx),%eax
80105491:	89 45 0c             	mov    %eax,0xc(%ebp)
80105494:	8b 45 08             	mov    0x8(%ebp),%eax
80105497:	8d 48 01             	lea    0x1(%eax),%ecx
8010549a:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010549d:	0f b6 12             	movzbl (%edx),%edx
801054a0:	88 10                	mov    %dl,(%eax)
801054a2:	0f b6 00             	movzbl (%eax),%eax
801054a5:	84 c0                	test   %al,%al
801054a7:	75 d5                	jne    8010547e <strncpy+0xd>
    ;
  while(n-- > 0)
801054a9:	eb 0c                	jmp    801054b7 <strncpy+0x46>
    *s++ = 0;
801054ab:	8b 45 08             	mov    0x8(%ebp),%eax
801054ae:	8d 50 01             	lea    0x1(%eax),%edx
801054b1:	89 55 08             	mov    %edx,0x8(%ebp)
801054b4:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801054b7:	8b 45 10             	mov    0x10(%ebp),%eax
801054ba:	8d 50 ff             	lea    -0x1(%eax),%edx
801054bd:	89 55 10             	mov    %edx,0x10(%ebp)
801054c0:	85 c0                	test   %eax,%eax
801054c2:	7f e7                	jg     801054ab <strncpy+0x3a>
  return os;
801054c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054c7:	c9                   	leave
801054c8:	c3                   	ret

801054c9 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801054c9:	55                   	push   %ebp
801054ca:	89 e5                	mov    %esp,%ebp
801054cc:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801054cf:	8b 45 08             	mov    0x8(%ebp),%eax
801054d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801054d5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054d9:	7f 05                	jg     801054e0 <safestrcpy+0x17>
    return os;
801054db:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054de:	eb 32                	jmp    80105512 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
801054e0:	90                   	nop
801054e1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054e5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054e9:	7e 1e                	jle    80105509 <safestrcpy+0x40>
801054eb:	8b 55 0c             	mov    0xc(%ebp),%edx
801054ee:	8d 42 01             	lea    0x1(%edx),%eax
801054f1:	89 45 0c             	mov    %eax,0xc(%ebp)
801054f4:	8b 45 08             	mov    0x8(%ebp),%eax
801054f7:	8d 48 01             	lea    0x1(%eax),%ecx
801054fa:	89 4d 08             	mov    %ecx,0x8(%ebp)
801054fd:	0f b6 12             	movzbl (%edx),%edx
80105500:	88 10                	mov    %dl,(%eax)
80105502:	0f b6 00             	movzbl (%eax),%eax
80105505:	84 c0                	test   %al,%al
80105507:	75 d8                	jne    801054e1 <safestrcpy+0x18>
    ;
  *s = 0;
80105509:	8b 45 08             	mov    0x8(%ebp),%eax
8010550c:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010550f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105512:	c9                   	leave
80105513:	c3                   	ret

80105514 <strlen>:

int
strlen(const char *s)
{
80105514:	55                   	push   %ebp
80105515:	89 e5                	mov    %esp,%ebp
80105517:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010551a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105521:	eb 04                	jmp    80105527 <strlen+0x13>
80105523:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105527:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010552a:	8b 45 08             	mov    0x8(%ebp),%eax
8010552d:	01 d0                	add    %edx,%eax
8010552f:	0f b6 00             	movzbl (%eax),%eax
80105532:	84 c0                	test   %al,%al
80105534:	75 ed                	jne    80105523 <strlen+0xf>
    ;
  return n;
80105536:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105539:	c9                   	leave
8010553a:	c3                   	ret

8010553b <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010553b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010553f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105543:	55                   	push   %ebp
  pushl %ebx
80105544:	53                   	push   %ebx
  pushl %esi
80105545:	56                   	push   %esi
  pushl %edi
80105546:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105547:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105549:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010554b:	5f                   	pop    %edi
  popl %esi
8010554c:	5e                   	pop    %esi
  popl %ebx
8010554d:	5b                   	pop    %ebx
  popl %ebp
8010554e:	5d                   	pop    %ebp
  ret
8010554f:	c3                   	ret

80105550 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105550:	55                   	push   %ebp
80105551:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105553:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105559:	8b 00                	mov    (%eax),%eax
8010555b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010555e:	73 12                	jae    80105572 <fetchint+0x22>
80105560:	8b 45 08             	mov    0x8(%ebp),%eax
80105563:	8d 50 04             	lea    0x4(%eax),%edx
80105566:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010556c:	8b 00                	mov    (%eax),%eax
8010556e:	39 d0                	cmp    %edx,%eax
80105570:	73 07                	jae    80105579 <fetchint+0x29>
    return -1;
80105572:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105577:	eb 0f                	jmp    80105588 <fetchint+0x38>
  *ip = *(int*)(addr);
80105579:	8b 45 08             	mov    0x8(%ebp),%eax
8010557c:	8b 10                	mov    (%eax),%edx
8010557e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105581:	89 10                	mov    %edx,(%eax)
  return 0;
80105583:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105588:	5d                   	pop    %ebp
80105589:	c3                   	ret

8010558a <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010558a:	55                   	push   %ebp
8010558b:	89 e5                	mov    %esp,%ebp
8010558d:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105590:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105596:	8b 00                	mov    (%eax),%eax
80105598:	39 45 08             	cmp    %eax,0x8(%ebp)
8010559b:	72 07                	jb     801055a4 <fetchstr+0x1a>
    return -1;
8010559d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055a2:	eb 44                	jmp    801055e8 <fetchstr+0x5e>
  *pp = (char*)addr;
801055a4:	8b 55 08             	mov    0x8(%ebp),%edx
801055a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801055aa:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801055ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055b2:	8b 00                	mov    (%eax),%eax
801055b4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801055b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ba:	8b 00                	mov    (%eax),%eax
801055bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
801055bf:	eb 1a                	jmp    801055db <fetchstr+0x51>
    if(*s == 0)
801055c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055c4:	0f b6 00             	movzbl (%eax),%eax
801055c7:	84 c0                	test   %al,%al
801055c9:	75 0c                	jne    801055d7 <fetchstr+0x4d>
      return s - *pp;
801055cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ce:	8b 10                	mov    (%eax),%edx
801055d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055d3:	29 d0                	sub    %edx,%eax
801055d5:	eb 11                	jmp    801055e8 <fetchstr+0x5e>
  for(s = *pp; s < ep; s++)
801055d7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055db:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055de:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801055e1:	72 de                	jb     801055c1 <fetchstr+0x37>
  return -1;
801055e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055e8:	c9                   	leave
801055e9:	c3                   	ret

801055ea <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801055ea:	55                   	push   %ebp
801055eb:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801055ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055f3:	8b 40 18             	mov    0x18(%eax),%eax
801055f6:	8b 40 44             	mov    0x44(%eax),%eax
801055f9:	8b 55 08             	mov    0x8(%ebp),%edx
801055fc:	c1 e2 02             	shl    $0x2,%edx
801055ff:	01 d0                	add    %edx,%eax
80105601:	83 c0 04             	add    $0x4,%eax
80105604:	ff 75 0c             	push   0xc(%ebp)
80105607:	50                   	push   %eax
80105608:	e8 43 ff ff ff       	call   80105550 <fetchint>
8010560d:	83 c4 08             	add    $0x8,%esp
}
80105610:	c9                   	leave
80105611:	c3                   	ret

80105612 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105612:	55                   	push   %ebp
80105613:	89 e5                	mov    %esp,%ebp
80105615:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105618:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010561b:	50                   	push   %eax
8010561c:	ff 75 08             	push   0x8(%ebp)
8010561f:	e8 c6 ff ff ff       	call   801055ea <argint>
80105624:	83 c4 08             	add    $0x8,%esp
80105627:	85 c0                	test   %eax,%eax
80105629:	79 07                	jns    80105632 <argptr+0x20>
    return -1;
8010562b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105630:	eb 3b                	jmp    8010566d <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105632:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105638:	8b 00                	mov    (%eax),%eax
8010563a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010563d:	39 c2                	cmp    %eax,%edx
8010563f:	73 16                	jae    80105657 <argptr+0x45>
80105641:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105644:	89 c2                	mov    %eax,%edx
80105646:	8b 45 10             	mov    0x10(%ebp),%eax
80105649:	01 c2                	add    %eax,%edx
8010564b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105651:	8b 00                	mov    (%eax),%eax
80105653:	39 d0                	cmp    %edx,%eax
80105655:	73 07                	jae    8010565e <argptr+0x4c>
    return -1;
80105657:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010565c:	eb 0f                	jmp    8010566d <argptr+0x5b>
  *pp = (char*)i;
8010565e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105661:	89 c2                	mov    %eax,%edx
80105663:	8b 45 0c             	mov    0xc(%ebp),%eax
80105666:	89 10                	mov    %edx,(%eax)
  return 0;
80105668:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010566d:	c9                   	leave
8010566e:	c3                   	ret

8010566f <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010566f:	55                   	push   %ebp
80105670:	89 e5                	mov    %esp,%ebp
80105672:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105675:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105678:	50                   	push   %eax
80105679:	ff 75 08             	push   0x8(%ebp)
8010567c:	e8 69 ff ff ff       	call   801055ea <argint>
80105681:	83 c4 08             	add    $0x8,%esp
80105684:	85 c0                	test   %eax,%eax
80105686:	79 07                	jns    8010568f <argstr+0x20>
    return -1;
80105688:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010568d:	eb 0f                	jmp    8010569e <argstr+0x2f>
  return fetchstr(addr, pp);
8010568f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105692:	ff 75 0c             	push   0xc(%ebp)
80105695:	50                   	push   %eax
80105696:	e8 ef fe ff ff       	call   8010558a <fetchstr>
8010569b:	83 c4 08             	add    $0x8,%esp
}
8010569e:	c9                   	leave
8010569f:	c3                   	ret

801056a0 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
801056a0:	55                   	push   %ebp
801056a1:	89 e5                	mov    %esp,%ebp
801056a3:	83 ec 18             	sub    $0x18,%esp
  int num;

  num = proc->tf->eax;
801056a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056ac:	8b 40 18             	mov    0x18(%eax),%eax
801056af:	8b 40 1c             	mov    0x1c(%eax),%eax
801056b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801056b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056b9:	7e 32                	jle    801056ed <syscall+0x4d>
801056bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056be:	83 f8 15             	cmp    $0x15,%eax
801056c1:	77 2a                	ja     801056ed <syscall+0x4d>
801056c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c6:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056cd:	85 c0                	test   %eax,%eax
801056cf:	74 1c                	je     801056ed <syscall+0x4d>
    proc->tf->eax = syscalls[num]();
801056d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056d4:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056db:	ff d0                	call   *%eax
801056dd:	89 c2                	mov    %eax,%edx
801056df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056e5:	8b 40 18             	mov    0x18(%eax),%eax
801056e8:	89 50 1c             	mov    %edx,0x1c(%eax)
801056eb:	eb 35                	jmp    80105722 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801056ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056f3:	8d 50 6c             	lea    0x6c(%eax),%edx
801056f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    cprintf("%d %s: unknown sys call %d\n",
801056fc:	8b 40 10             	mov    0x10(%eax),%eax
801056ff:	ff 75 f4             	push   -0xc(%ebp)
80105702:	52                   	push   %edx
80105703:	50                   	push   %eax
80105704:	68 ef 89 10 80       	push   $0x801089ef
80105709:	e8 b6 ac ff ff       	call   801003c4 <cprintf>
8010570e:	83 c4 10             	add    $0x10,%esp
    proc->tf->eax = -1;
80105711:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105717:	8b 40 18             	mov    0x18(%eax),%eax
8010571a:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105721:	90                   	nop
80105722:	90                   	nop
80105723:	c9                   	leave
80105724:	c3                   	ret

80105725 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105725:	55                   	push   %ebp
80105726:	89 e5                	mov    %esp,%ebp
80105728:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010572b:	83 ec 08             	sub    $0x8,%esp
8010572e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105731:	50                   	push   %eax
80105732:	ff 75 08             	push   0x8(%ebp)
80105735:	e8 b0 fe ff ff       	call   801055ea <argint>
8010573a:	83 c4 10             	add    $0x10,%esp
8010573d:	85 c0                	test   %eax,%eax
8010573f:	79 07                	jns    80105748 <argfd+0x23>
    return -1;
80105741:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105746:	eb 50                	jmp    80105798 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105748:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010574b:	85 c0                	test   %eax,%eax
8010574d:	78 21                	js     80105770 <argfd+0x4b>
8010574f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105752:	83 f8 0f             	cmp    $0xf,%eax
80105755:	7f 19                	jg     80105770 <argfd+0x4b>
80105757:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010575d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105760:	83 c2 08             	add    $0x8,%edx
80105763:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105767:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010576a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010576e:	75 07                	jne    80105777 <argfd+0x52>
    return -1;
80105770:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105775:	eb 21                	jmp    80105798 <argfd+0x73>
  if(pfd)
80105777:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010577b:	74 08                	je     80105785 <argfd+0x60>
    *pfd = fd;
8010577d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105780:	8b 45 0c             	mov    0xc(%ebp),%eax
80105783:	89 10                	mov    %edx,(%eax)
  if(pf)
80105785:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105789:	74 08                	je     80105793 <argfd+0x6e>
    *pf = f;
8010578b:	8b 45 10             	mov    0x10(%ebp),%eax
8010578e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105791:	89 10                	mov    %edx,(%eax)
  return 0;
80105793:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105798:	c9                   	leave
80105799:	c3                   	ret

8010579a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010579a:	55                   	push   %ebp
8010579b:	89 e5                	mov    %esp,%ebp
8010579d:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801057a0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057a7:	eb 30                	jmp    801057d9 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801057a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057af:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057b2:	83 c2 08             	add    $0x8,%edx
801057b5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057b9:	85 c0                	test   %eax,%eax
801057bb:	75 18                	jne    801057d5 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801057bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057c3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057c6:	8d 4a 08             	lea    0x8(%edx),%ecx
801057c9:	8b 55 08             	mov    0x8(%ebp),%edx
801057cc:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801057d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057d3:	eb 0f                	jmp    801057e4 <fdalloc+0x4a>
  for(fd = 0; fd < NOFILE; fd++){
801057d5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057d9:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801057dd:	7e ca                	jle    801057a9 <fdalloc+0xf>
    }
  }
  return -1;
801057df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057e4:	c9                   	leave
801057e5:	c3                   	ret

801057e6 <sys_dup>:

int
sys_dup(void)
{
801057e6:	55                   	push   %ebp
801057e7:	89 e5                	mov    %esp,%ebp
801057e9:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801057ec:	83 ec 04             	sub    $0x4,%esp
801057ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057f2:	50                   	push   %eax
801057f3:	6a 00                	push   $0x0
801057f5:	6a 00                	push   $0x0
801057f7:	e8 29 ff ff ff       	call   80105725 <argfd>
801057fc:	83 c4 10             	add    $0x10,%esp
801057ff:	85 c0                	test   %eax,%eax
80105801:	79 07                	jns    8010580a <sys_dup+0x24>
    return -1;
80105803:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105808:	eb 31                	jmp    8010583b <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010580a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010580d:	83 ec 0c             	sub    $0xc,%esp
80105810:	50                   	push   %eax
80105811:	e8 84 ff ff ff       	call   8010579a <fdalloc>
80105816:	83 c4 10             	add    $0x10,%esp
80105819:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010581c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105820:	79 07                	jns    80105829 <sys_dup+0x43>
    return -1;
80105822:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105827:	eb 12                	jmp    8010583b <sys_dup+0x55>
  filedup(f);
80105829:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010582c:	83 ec 0c             	sub    $0xc,%esp
8010582f:	50                   	push   %eax
80105830:	e8 fc b7 ff ff       	call   80101031 <filedup>
80105835:	83 c4 10             	add    $0x10,%esp
  return fd;
80105838:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010583b:	c9                   	leave
8010583c:	c3                   	ret

8010583d <sys_read>:

int
sys_read(void)
{
8010583d:	55                   	push   %ebp
8010583e:	89 e5                	mov    %esp,%ebp
80105840:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105843:	83 ec 04             	sub    $0x4,%esp
80105846:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105849:	50                   	push   %eax
8010584a:	6a 00                	push   $0x0
8010584c:	6a 00                	push   $0x0
8010584e:	e8 d2 fe ff ff       	call   80105725 <argfd>
80105853:	83 c4 10             	add    $0x10,%esp
80105856:	85 c0                	test   %eax,%eax
80105858:	78 2e                	js     80105888 <sys_read+0x4b>
8010585a:	83 ec 08             	sub    $0x8,%esp
8010585d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105860:	50                   	push   %eax
80105861:	6a 02                	push   $0x2
80105863:	e8 82 fd ff ff       	call   801055ea <argint>
80105868:	83 c4 10             	add    $0x10,%esp
8010586b:	85 c0                	test   %eax,%eax
8010586d:	78 19                	js     80105888 <sys_read+0x4b>
8010586f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105872:	83 ec 04             	sub    $0x4,%esp
80105875:	50                   	push   %eax
80105876:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105879:	50                   	push   %eax
8010587a:	6a 01                	push   $0x1
8010587c:	e8 91 fd ff ff       	call   80105612 <argptr>
80105881:	83 c4 10             	add    $0x10,%esp
80105884:	85 c0                	test   %eax,%eax
80105886:	79 07                	jns    8010588f <sys_read+0x52>
    return -1;
80105888:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010588d:	eb 17                	jmp    801058a6 <sys_read+0x69>
  return fileread(f, p, n);
8010588f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105892:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105898:	83 ec 04             	sub    $0x4,%esp
8010589b:	51                   	push   %ecx
8010589c:	52                   	push   %edx
8010589d:	50                   	push   %eax
8010589e:	e8 1e b9 ff ff       	call   801011c1 <fileread>
801058a3:	83 c4 10             	add    $0x10,%esp
}
801058a6:	c9                   	leave
801058a7:	c3                   	ret

801058a8 <sys_write>:

int
sys_write(void)
{
801058a8:	55                   	push   %ebp
801058a9:	89 e5                	mov    %esp,%ebp
801058ab:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058ae:	83 ec 04             	sub    $0x4,%esp
801058b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058b4:	50                   	push   %eax
801058b5:	6a 00                	push   $0x0
801058b7:	6a 00                	push   $0x0
801058b9:	e8 67 fe ff ff       	call   80105725 <argfd>
801058be:	83 c4 10             	add    $0x10,%esp
801058c1:	85 c0                	test   %eax,%eax
801058c3:	78 2e                	js     801058f3 <sys_write+0x4b>
801058c5:	83 ec 08             	sub    $0x8,%esp
801058c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058cb:	50                   	push   %eax
801058cc:	6a 02                	push   $0x2
801058ce:	e8 17 fd ff ff       	call   801055ea <argint>
801058d3:	83 c4 10             	add    $0x10,%esp
801058d6:	85 c0                	test   %eax,%eax
801058d8:	78 19                	js     801058f3 <sys_write+0x4b>
801058da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058dd:	83 ec 04             	sub    $0x4,%esp
801058e0:	50                   	push   %eax
801058e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058e4:	50                   	push   %eax
801058e5:	6a 01                	push   $0x1
801058e7:	e8 26 fd ff ff       	call   80105612 <argptr>
801058ec:	83 c4 10             	add    $0x10,%esp
801058ef:	85 c0                	test   %eax,%eax
801058f1:	79 07                	jns    801058fa <sys_write+0x52>
    return -1;
801058f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058f8:	eb 17                	jmp    80105911 <sys_write+0x69>
  return filewrite(f, p, n);
801058fa:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801058fd:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105900:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105903:	83 ec 04             	sub    $0x4,%esp
80105906:	51                   	push   %ecx
80105907:	52                   	push   %edx
80105908:	50                   	push   %eax
80105909:	e8 6b b9 ff ff       	call   80101279 <filewrite>
8010590e:	83 c4 10             	add    $0x10,%esp
}
80105911:	c9                   	leave
80105912:	c3                   	ret

80105913 <sys_close>:

int
sys_close(void)
{
80105913:	55                   	push   %ebp
80105914:	89 e5                	mov    %esp,%ebp
80105916:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105919:	83 ec 04             	sub    $0x4,%esp
8010591c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010591f:	50                   	push   %eax
80105920:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105923:	50                   	push   %eax
80105924:	6a 00                	push   $0x0
80105926:	e8 fa fd ff ff       	call   80105725 <argfd>
8010592b:	83 c4 10             	add    $0x10,%esp
8010592e:	85 c0                	test   %eax,%eax
80105930:	79 07                	jns    80105939 <sys_close+0x26>
    return -1;
80105932:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105937:	eb 28                	jmp    80105961 <sys_close+0x4e>
  proc->ofile[fd] = 0;
80105939:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010593f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105942:	83 c2 08             	add    $0x8,%edx
80105945:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010594c:	00 
  fileclose(f);
8010594d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105950:	83 ec 0c             	sub    $0xc,%esp
80105953:	50                   	push   %eax
80105954:	e8 29 b7 ff ff       	call   80101082 <fileclose>
80105959:	83 c4 10             	add    $0x10,%esp
  return 0;
8010595c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105961:	c9                   	leave
80105962:	c3                   	ret

80105963 <sys_fstat>:

int
sys_fstat(void)
{
80105963:	55                   	push   %ebp
80105964:	89 e5                	mov    %esp,%ebp
80105966:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105969:	83 ec 04             	sub    $0x4,%esp
8010596c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010596f:	50                   	push   %eax
80105970:	6a 00                	push   $0x0
80105972:	6a 00                	push   $0x0
80105974:	e8 ac fd ff ff       	call   80105725 <argfd>
80105979:	83 c4 10             	add    $0x10,%esp
8010597c:	85 c0                	test   %eax,%eax
8010597e:	78 17                	js     80105997 <sys_fstat+0x34>
80105980:	83 ec 04             	sub    $0x4,%esp
80105983:	6a 14                	push   $0x14
80105985:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105988:	50                   	push   %eax
80105989:	6a 01                	push   $0x1
8010598b:	e8 82 fc ff ff       	call   80105612 <argptr>
80105990:	83 c4 10             	add    $0x10,%esp
80105993:	85 c0                	test   %eax,%eax
80105995:	79 07                	jns    8010599e <sys_fstat+0x3b>
    return -1;
80105997:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010599c:	eb 13                	jmp    801059b1 <sys_fstat+0x4e>
  return filestat(f, st);
8010599e:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a4:	83 ec 08             	sub    $0x8,%esp
801059a7:	52                   	push   %edx
801059a8:	50                   	push   %eax
801059a9:	e8 bc b7 ff ff       	call   8010116a <filestat>
801059ae:	83 c4 10             	add    $0x10,%esp
}
801059b1:	c9                   	leave
801059b2:	c3                   	ret

801059b3 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801059b3:	55                   	push   %ebp
801059b4:	89 e5                	mov    %esp,%ebp
801059b6:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801059b9:	83 ec 08             	sub    $0x8,%esp
801059bc:	8d 45 d8             	lea    -0x28(%ebp),%eax
801059bf:	50                   	push   %eax
801059c0:	6a 00                	push   $0x0
801059c2:	e8 a8 fc ff ff       	call   8010566f <argstr>
801059c7:	83 c4 10             	add    $0x10,%esp
801059ca:	85 c0                	test   %eax,%eax
801059cc:	78 15                	js     801059e3 <sys_link+0x30>
801059ce:	83 ec 08             	sub    $0x8,%esp
801059d1:	8d 45 dc             	lea    -0x24(%ebp),%eax
801059d4:	50                   	push   %eax
801059d5:	6a 01                	push   $0x1
801059d7:	e8 93 fc ff ff       	call   8010566f <argstr>
801059dc:	83 c4 10             	add    $0x10,%esp
801059df:	85 c0                	test   %eax,%eax
801059e1:	79 0a                	jns    801059ed <sys_link+0x3a>
    return -1;
801059e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059e8:	e9 68 01 00 00       	jmp    80105b55 <sys_link+0x1a2>

  begin_op();
801059ed:	e8 64 db ff ff       	call   80103556 <begin_op>
  if((ip = namei(old)) == 0){
801059f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801059f5:	83 ec 0c             	sub    $0xc,%esp
801059f8:	50                   	push   %eax
801059f9:	e8 3c cb ff ff       	call   8010253a <namei>
801059fe:	83 c4 10             	add    $0x10,%esp
80105a01:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a04:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a08:	75 0f                	jne    80105a19 <sys_link+0x66>
    end_op();
80105a0a:	e8 d3 db ff ff       	call   801035e2 <end_op>
    return -1;
80105a0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a14:	e9 3c 01 00 00       	jmp    80105b55 <sys_link+0x1a2>
  }

  ilock(ip);
80105a19:	83 ec 0c             	sub    $0xc,%esp
80105a1c:	ff 75 f4             	push   -0xc(%ebp)
80105a1f:	e8 65 bf ff ff       	call   80101989 <ilock>
80105a24:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a2a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a2e:	66 83 f8 01          	cmp    $0x1,%ax
80105a32:	75 1d                	jne    80105a51 <sys_link+0x9e>
    iunlockput(ip);
80105a34:	83 ec 0c             	sub    $0xc,%esp
80105a37:	ff 75 f4             	push   -0xc(%ebp)
80105a3a:	e8 0a c2 ff ff       	call   80101c49 <iunlockput>
80105a3f:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a42:	e8 9b db ff ff       	call   801035e2 <end_op>
    return -1;
80105a47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a4c:	e9 04 01 00 00       	jmp    80105b55 <sys_link+0x1a2>
  }

  ip->nlink++;
80105a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a54:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105a58:	83 c0 01             	add    $0x1,%eax
80105a5b:	89 c2                	mov    %eax,%edx
80105a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a60:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105a64:	83 ec 0c             	sub    $0xc,%esp
80105a67:	ff 75 f4             	push   -0xc(%ebp)
80105a6a:	e8 40 bd ff ff       	call   801017af <iupdate>
80105a6f:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105a72:	83 ec 0c             	sub    $0xc,%esp
80105a75:	ff 75 f4             	push   -0xc(%ebp)
80105a78:	e8 6a c0 ff ff       	call   80101ae7 <iunlock>
80105a7d:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105a80:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105a83:	83 ec 08             	sub    $0x8,%esp
80105a86:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105a89:	52                   	push   %edx
80105a8a:	50                   	push   %eax
80105a8b:	e8 c6 ca ff ff       	call   80102556 <nameiparent>
80105a90:	83 c4 10             	add    $0x10,%esp
80105a93:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a96:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a9a:	74 71                	je     80105b0d <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105a9c:	83 ec 0c             	sub    $0xc,%esp
80105a9f:	ff 75 f0             	push   -0x10(%ebp)
80105aa2:	e8 e2 be ff ff       	call   80101989 <ilock>
80105aa7:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105aaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aad:	8b 10                	mov    (%eax),%edx
80105aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab2:	8b 00                	mov    (%eax),%eax
80105ab4:	39 c2                	cmp    %eax,%edx
80105ab6:	75 1d                	jne    80105ad5 <sys_link+0x122>
80105ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105abb:	8b 40 04             	mov    0x4(%eax),%eax
80105abe:	83 ec 04             	sub    $0x4,%esp
80105ac1:	50                   	push   %eax
80105ac2:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105ac5:	50                   	push   %eax
80105ac6:	ff 75 f0             	push   -0x10(%ebp)
80105ac9:	e8 d4 c7 ff ff       	call   801022a2 <dirlink>
80105ace:	83 c4 10             	add    $0x10,%esp
80105ad1:	85 c0                	test   %eax,%eax
80105ad3:	79 10                	jns    80105ae5 <sys_link+0x132>
    iunlockput(dp);
80105ad5:	83 ec 0c             	sub    $0xc,%esp
80105ad8:	ff 75 f0             	push   -0x10(%ebp)
80105adb:	e8 69 c1 ff ff       	call   80101c49 <iunlockput>
80105ae0:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105ae3:	eb 29                	jmp    80105b0e <sys_link+0x15b>
  }
  iunlockput(dp);
80105ae5:	83 ec 0c             	sub    $0xc,%esp
80105ae8:	ff 75 f0             	push   -0x10(%ebp)
80105aeb:	e8 59 c1 ff ff       	call   80101c49 <iunlockput>
80105af0:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105af3:	83 ec 0c             	sub    $0xc,%esp
80105af6:	ff 75 f4             	push   -0xc(%ebp)
80105af9:	e8 5b c0 ff ff       	call   80101b59 <iput>
80105afe:	83 c4 10             	add    $0x10,%esp

  end_op();
80105b01:	e8 dc da ff ff       	call   801035e2 <end_op>

  return 0;
80105b06:	b8 00 00 00 00       	mov    $0x0,%eax
80105b0b:	eb 48                	jmp    80105b55 <sys_link+0x1a2>
    goto bad;
80105b0d:	90                   	nop

bad:
  ilock(ip);
80105b0e:	83 ec 0c             	sub    $0xc,%esp
80105b11:	ff 75 f4             	push   -0xc(%ebp)
80105b14:	e8 70 be ff ff       	call   80101989 <ilock>
80105b19:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b1f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b23:	83 e8 01             	sub    $0x1,%eax
80105b26:	89 c2                	mov    %eax,%edx
80105b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b2b:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b2f:	83 ec 0c             	sub    $0xc,%esp
80105b32:	ff 75 f4             	push   -0xc(%ebp)
80105b35:	e8 75 bc ff ff       	call   801017af <iupdate>
80105b3a:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105b3d:	83 ec 0c             	sub    $0xc,%esp
80105b40:	ff 75 f4             	push   -0xc(%ebp)
80105b43:	e8 01 c1 ff ff       	call   80101c49 <iunlockput>
80105b48:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b4b:	e8 92 da ff ff       	call   801035e2 <end_op>
  return -1;
80105b50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b55:	c9                   	leave
80105b56:	c3                   	ret

80105b57 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105b57:	55                   	push   %ebp
80105b58:	89 e5                	mov    %esp,%ebp
80105b5a:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b5d:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105b64:	eb 40                	jmp    80105ba6 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b69:	6a 10                	push   $0x10
80105b6b:	50                   	push   %eax
80105b6c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b6f:	50                   	push   %eax
80105b70:	ff 75 08             	push   0x8(%ebp)
80105b73:	e8 7a c3 ff ff       	call   80101ef2 <readi>
80105b78:	83 c4 10             	add    $0x10,%esp
80105b7b:	83 f8 10             	cmp    $0x10,%eax
80105b7e:	74 0d                	je     80105b8d <isdirempty+0x36>
      panic("isdirempty: readi");
80105b80:	83 ec 0c             	sub    $0xc,%esp
80105b83:	68 0b 8a 10 80       	push   $0x80108a0b
80105b88:	e8 ec a9 ff ff       	call   80100579 <panic>
    if(de.inum != 0)
80105b8d:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105b91:	66 85 c0             	test   %ax,%ax
80105b94:	74 07                	je     80105b9d <isdirempty+0x46>
      return 0;
80105b96:	b8 00 00 00 00       	mov    $0x0,%eax
80105b9b:	eb 1b                	jmp    80105bb8 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba0:	83 c0 10             	add    $0x10,%eax
80105ba3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ba6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ba9:	8b 40 18             	mov    0x18(%eax),%eax
80105bac:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105baf:	39 c2                	cmp    %eax,%edx
80105bb1:	72 b3                	jb     80105b66 <isdirempty+0xf>
  }
  return 1;
80105bb3:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105bb8:	c9                   	leave
80105bb9:	c3                   	ret

80105bba <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105bba:	55                   	push   %ebp
80105bbb:	89 e5                	mov    %esp,%ebp
80105bbd:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105bc0:	83 ec 08             	sub    $0x8,%esp
80105bc3:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105bc6:	50                   	push   %eax
80105bc7:	6a 00                	push   $0x0
80105bc9:	e8 a1 fa ff ff       	call   8010566f <argstr>
80105bce:	83 c4 10             	add    $0x10,%esp
80105bd1:	85 c0                	test   %eax,%eax
80105bd3:	79 0a                	jns    80105bdf <sys_unlink+0x25>
    return -1;
80105bd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bda:	e9 bf 01 00 00       	jmp    80105d9e <sys_unlink+0x1e4>

  begin_op();
80105bdf:	e8 72 d9 ff ff       	call   80103556 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105be4:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105be7:	83 ec 08             	sub    $0x8,%esp
80105bea:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105bed:	52                   	push   %edx
80105bee:	50                   	push   %eax
80105bef:	e8 62 c9 ff ff       	call   80102556 <nameiparent>
80105bf4:	83 c4 10             	add    $0x10,%esp
80105bf7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bfa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bfe:	75 0f                	jne    80105c0f <sys_unlink+0x55>
    end_op();
80105c00:	e8 dd d9 ff ff       	call   801035e2 <end_op>
    return -1;
80105c05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c0a:	e9 8f 01 00 00       	jmp    80105d9e <sys_unlink+0x1e4>
  }

  ilock(dp);
80105c0f:	83 ec 0c             	sub    $0xc,%esp
80105c12:	ff 75 f4             	push   -0xc(%ebp)
80105c15:	e8 6f bd ff ff       	call   80101989 <ilock>
80105c1a:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105c1d:	83 ec 08             	sub    $0x8,%esp
80105c20:	68 1d 8a 10 80       	push   $0x80108a1d
80105c25:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c28:	50                   	push   %eax
80105c29:	e8 9f c5 ff ff       	call   801021cd <namecmp>
80105c2e:	83 c4 10             	add    $0x10,%esp
80105c31:	85 c0                	test   %eax,%eax
80105c33:	0f 84 49 01 00 00    	je     80105d82 <sys_unlink+0x1c8>
80105c39:	83 ec 08             	sub    $0x8,%esp
80105c3c:	68 1f 8a 10 80       	push   $0x80108a1f
80105c41:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c44:	50                   	push   %eax
80105c45:	e8 83 c5 ff ff       	call   801021cd <namecmp>
80105c4a:	83 c4 10             	add    $0x10,%esp
80105c4d:	85 c0                	test   %eax,%eax
80105c4f:	0f 84 2d 01 00 00    	je     80105d82 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105c55:	83 ec 04             	sub    $0x4,%esp
80105c58:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105c5b:	50                   	push   %eax
80105c5c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c5f:	50                   	push   %eax
80105c60:	ff 75 f4             	push   -0xc(%ebp)
80105c63:	e8 80 c5 ff ff       	call   801021e8 <dirlookup>
80105c68:	83 c4 10             	add    $0x10,%esp
80105c6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c6e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c72:	0f 84 0d 01 00 00    	je     80105d85 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105c78:	83 ec 0c             	sub    $0xc,%esp
80105c7b:	ff 75 f0             	push   -0x10(%ebp)
80105c7e:	e8 06 bd ff ff       	call   80101989 <ilock>
80105c83:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105c86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c89:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c8d:	66 85 c0             	test   %ax,%ax
80105c90:	7f 0d                	jg     80105c9f <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105c92:	83 ec 0c             	sub    $0xc,%esp
80105c95:	68 22 8a 10 80       	push   $0x80108a22
80105c9a:	e8 da a8 ff ff       	call   80100579 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105c9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ca6:	66 83 f8 01          	cmp    $0x1,%ax
80105caa:	75 25                	jne    80105cd1 <sys_unlink+0x117>
80105cac:	83 ec 0c             	sub    $0xc,%esp
80105caf:	ff 75 f0             	push   -0x10(%ebp)
80105cb2:	e8 a0 fe ff ff       	call   80105b57 <isdirempty>
80105cb7:	83 c4 10             	add    $0x10,%esp
80105cba:	85 c0                	test   %eax,%eax
80105cbc:	75 13                	jne    80105cd1 <sys_unlink+0x117>
    iunlockput(ip);
80105cbe:	83 ec 0c             	sub    $0xc,%esp
80105cc1:	ff 75 f0             	push   -0x10(%ebp)
80105cc4:	e8 80 bf ff ff       	call   80101c49 <iunlockput>
80105cc9:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105ccc:	e9 b5 00 00 00       	jmp    80105d86 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105cd1:	83 ec 04             	sub    $0x4,%esp
80105cd4:	6a 10                	push   $0x10
80105cd6:	6a 00                	push   $0x0
80105cd8:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105cdb:	50                   	push   %eax
80105cdc:	e8 e5 f5 ff ff       	call   801052c6 <memset>
80105ce1:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ce4:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105ce7:	6a 10                	push   $0x10
80105ce9:	50                   	push   %eax
80105cea:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ced:	50                   	push   %eax
80105cee:	ff 75 f4             	push   -0xc(%ebp)
80105cf1:	e8 51 c3 ff ff       	call   80102047 <writei>
80105cf6:	83 c4 10             	add    $0x10,%esp
80105cf9:	83 f8 10             	cmp    $0x10,%eax
80105cfc:	74 0d                	je     80105d0b <sys_unlink+0x151>
    panic("unlink: writei");
80105cfe:	83 ec 0c             	sub    $0xc,%esp
80105d01:	68 34 8a 10 80       	push   $0x80108a34
80105d06:	e8 6e a8 ff ff       	call   80100579 <panic>
  if(ip->type == T_DIR){
80105d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d0e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d12:	66 83 f8 01          	cmp    $0x1,%ax
80105d16:	75 21                	jne    80105d39 <sys_unlink+0x17f>
    dp->nlink--;
80105d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d1b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d1f:	83 e8 01             	sub    $0x1,%eax
80105d22:	89 c2                	mov    %eax,%edx
80105d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d27:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105d2b:	83 ec 0c             	sub    $0xc,%esp
80105d2e:	ff 75 f4             	push   -0xc(%ebp)
80105d31:	e8 79 ba ff ff       	call   801017af <iupdate>
80105d36:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105d39:	83 ec 0c             	sub    $0xc,%esp
80105d3c:	ff 75 f4             	push   -0xc(%ebp)
80105d3f:	e8 05 bf ff ff       	call   80101c49 <iunlockput>
80105d44:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105d47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d4a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d4e:	83 e8 01             	sub    $0x1,%eax
80105d51:	89 c2                	mov    %eax,%edx
80105d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d56:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d5a:	83 ec 0c             	sub    $0xc,%esp
80105d5d:	ff 75 f0             	push   -0x10(%ebp)
80105d60:	e8 4a ba ff ff       	call   801017af <iupdate>
80105d65:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105d68:	83 ec 0c             	sub    $0xc,%esp
80105d6b:	ff 75 f0             	push   -0x10(%ebp)
80105d6e:	e8 d6 be ff ff       	call   80101c49 <iunlockput>
80105d73:	83 c4 10             	add    $0x10,%esp

  end_op();
80105d76:	e8 67 d8 ff ff       	call   801035e2 <end_op>

  return 0;
80105d7b:	b8 00 00 00 00       	mov    $0x0,%eax
80105d80:	eb 1c                	jmp    80105d9e <sys_unlink+0x1e4>
    goto bad;
80105d82:	90                   	nop
80105d83:	eb 01                	jmp    80105d86 <sys_unlink+0x1cc>
    goto bad;
80105d85:	90                   	nop

bad:
  iunlockput(dp);
80105d86:	83 ec 0c             	sub    $0xc,%esp
80105d89:	ff 75 f4             	push   -0xc(%ebp)
80105d8c:	e8 b8 be ff ff       	call   80101c49 <iunlockput>
80105d91:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d94:	e8 49 d8 ff ff       	call   801035e2 <end_op>
  return -1;
80105d99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d9e:	c9                   	leave
80105d9f:	c3                   	ret

80105da0 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105da0:	55                   	push   %ebp
80105da1:	89 e5                	mov    %esp,%ebp
80105da3:	83 ec 38             	sub    $0x38,%esp
80105da6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105da9:	8b 55 10             	mov    0x10(%ebp),%edx
80105dac:	8b 45 14             	mov    0x14(%ebp),%eax
80105daf:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105db3:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105db7:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105dbb:	83 ec 08             	sub    $0x8,%esp
80105dbe:	8d 45 de             	lea    -0x22(%ebp),%eax
80105dc1:	50                   	push   %eax
80105dc2:	ff 75 08             	push   0x8(%ebp)
80105dc5:	e8 8c c7 ff ff       	call   80102556 <nameiparent>
80105dca:	83 c4 10             	add    $0x10,%esp
80105dcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105dd0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dd4:	75 0a                	jne    80105de0 <create+0x40>
    return 0;
80105dd6:	b8 00 00 00 00       	mov    $0x0,%eax
80105ddb:	e9 90 01 00 00       	jmp    80105f70 <create+0x1d0>
  ilock(dp);
80105de0:	83 ec 0c             	sub    $0xc,%esp
80105de3:	ff 75 f4             	push   -0xc(%ebp)
80105de6:	e8 9e bb ff ff       	call   80101989 <ilock>
80105deb:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105dee:	83 ec 04             	sub    $0x4,%esp
80105df1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105df4:	50                   	push   %eax
80105df5:	8d 45 de             	lea    -0x22(%ebp),%eax
80105df8:	50                   	push   %eax
80105df9:	ff 75 f4             	push   -0xc(%ebp)
80105dfc:	e8 e7 c3 ff ff       	call   801021e8 <dirlookup>
80105e01:	83 c4 10             	add    $0x10,%esp
80105e04:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e07:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e0b:	74 50                	je     80105e5d <create+0xbd>
    iunlockput(dp);
80105e0d:	83 ec 0c             	sub    $0xc,%esp
80105e10:	ff 75 f4             	push   -0xc(%ebp)
80105e13:	e8 31 be ff ff       	call   80101c49 <iunlockput>
80105e18:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105e1b:	83 ec 0c             	sub    $0xc,%esp
80105e1e:	ff 75 f0             	push   -0x10(%ebp)
80105e21:	e8 63 bb ff ff       	call   80101989 <ilock>
80105e26:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105e29:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105e2e:	75 15                	jne    80105e45 <create+0xa5>
80105e30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e33:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e37:	66 83 f8 02          	cmp    $0x2,%ax
80105e3b:	75 08                	jne    80105e45 <create+0xa5>
      return ip;
80105e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e40:	e9 2b 01 00 00       	jmp    80105f70 <create+0x1d0>
    iunlockput(ip);
80105e45:	83 ec 0c             	sub    $0xc,%esp
80105e48:	ff 75 f0             	push   -0x10(%ebp)
80105e4b:	e8 f9 bd ff ff       	call   80101c49 <iunlockput>
80105e50:	83 c4 10             	add    $0x10,%esp
    return 0;
80105e53:	b8 00 00 00 00       	mov    $0x0,%eax
80105e58:	e9 13 01 00 00       	jmp    80105f70 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105e5d:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e64:	8b 00                	mov    (%eax),%eax
80105e66:	83 ec 08             	sub    $0x8,%esp
80105e69:	52                   	push   %edx
80105e6a:	50                   	push   %eax
80105e6b:	e8 69 b8 ff ff       	call   801016d9 <ialloc>
80105e70:	83 c4 10             	add    $0x10,%esp
80105e73:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e76:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e7a:	75 0d                	jne    80105e89 <create+0xe9>
    panic("create: ialloc");
80105e7c:	83 ec 0c             	sub    $0xc,%esp
80105e7f:	68 43 8a 10 80       	push   $0x80108a43
80105e84:	e8 f0 a6 ff ff       	call   80100579 <panic>

  ilock(ip);
80105e89:	83 ec 0c             	sub    $0xc,%esp
80105e8c:	ff 75 f0             	push   -0x10(%ebp)
80105e8f:	e8 f5 ba ff ff       	call   80101989 <ilock>
80105e94:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105e97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e9a:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105e9e:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105ea2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea5:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105ea9:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105ead:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb0:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105eb6:	83 ec 0c             	sub    $0xc,%esp
80105eb9:	ff 75 f0             	push   -0x10(%ebp)
80105ebc:	e8 ee b8 ff ff       	call   801017af <iupdate>
80105ec1:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105ec4:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105ec9:	75 6a                	jne    80105f35 <create+0x195>
    dp->nlink++;  // for ".."
80105ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ece:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ed2:	83 c0 01             	add    $0x1,%eax
80105ed5:	89 c2                	mov    %eax,%edx
80105ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eda:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105ede:	83 ec 0c             	sub    $0xc,%esp
80105ee1:	ff 75 f4             	push   -0xc(%ebp)
80105ee4:	e8 c6 b8 ff ff       	call   801017af <iupdate>
80105ee9:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105eec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eef:	8b 40 04             	mov    0x4(%eax),%eax
80105ef2:	83 ec 04             	sub    $0x4,%esp
80105ef5:	50                   	push   %eax
80105ef6:	68 1d 8a 10 80       	push   $0x80108a1d
80105efb:	ff 75 f0             	push   -0x10(%ebp)
80105efe:	e8 9f c3 ff ff       	call   801022a2 <dirlink>
80105f03:	83 c4 10             	add    $0x10,%esp
80105f06:	85 c0                	test   %eax,%eax
80105f08:	78 1e                	js     80105f28 <create+0x188>
80105f0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f0d:	8b 40 04             	mov    0x4(%eax),%eax
80105f10:	83 ec 04             	sub    $0x4,%esp
80105f13:	50                   	push   %eax
80105f14:	68 1f 8a 10 80       	push   $0x80108a1f
80105f19:	ff 75 f0             	push   -0x10(%ebp)
80105f1c:	e8 81 c3 ff ff       	call   801022a2 <dirlink>
80105f21:	83 c4 10             	add    $0x10,%esp
80105f24:	85 c0                	test   %eax,%eax
80105f26:	79 0d                	jns    80105f35 <create+0x195>
      panic("create dots");
80105f28:	83 ec 0c             	sub    $0xc,%esp
80105f2b:	68 52 8a 10 80       	push   $0x80108a52
80105f30:	e8 44 a6 ff ff       	call   80100579 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105f35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f38:	8b 40 04             	mov    0x4(%eax),%eax
80105f3b:	83 ec 04             	sub    $0x4,%esp
80105f3e:	50                   	push   %eax
80105f3f:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f42:	50                   	push   %eax
80105f43:	ff 75 f4             	push   -0xc(%ebp)
80105f46:	e8 57 c3 ff ff       	call   801022a2 <dirlink>
80105f4b:	83 c4 10             	add    $0x10,%esp
80105f4e:	85 c0                	test   %eax,%eax
80105f50:	79 0d                	jns    80105f5f <create+0x1bf>
    panic("create: dirlink");
80105f52:	83 ec 0c             	sub    $0xc,%esp
80105f55:	68 5e 8a 10 80       	push   $0x80108a5e
80105f5a:	e8 1a a6 ff ff       	call   80100579 <panic>

  iunlockput(dp);
80105f5f:	83 ec 0c             	sub    $0xc,%esp
80105f62:	ff 75 f4             	push   -0xc(%ebp)
80105f65:	e8 df bc ff ff       	call   80101c49 <iunlockput>
80105f6a:	83 c4 10             	add    $0x10,%esp

  return ip;
80105f6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105f70:	c9                   	leave
80105f71:	c3                   	ret

80105f72 <sys_open>:

int
sys_open(void)
{
80105f72:	55                   	push   %ebp
80105f73:	89 e5                	mov    %esp,%ebp
80105f75:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105f78:	83 ec 08             	sub    $0x8,%esp
80105f7b:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f7e:	50                   	push   %eax
80105f7f:	6a 00                	push   $0x0
80105f81:	e8 e9 f6 ff ff       	call   8010566f <argstr>
80105f86:	83 c4 10             	add    $0x10,%esp
80105f89:	85 c0                	test   %eax,%eax
80105f8b:	78 15                	js     80105fa2 <sys_open+0x30>
80105f8d:	83 ec 08             	sub    $0x8,%esp
80105f90:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f93:	50                   	push   %eax
80105f94:	6a 01                	push   $0x1
80105f96:	e8 4f f6 ff ff       	call   801055ea <argint>
80105f9b:	83 c4 10             	add    $0x10,%esp
80105f9e:	85 c0                	test   %eax,%eax
80105fa0:	79 0a                	jns    80105fac <sys_open+0x3a>
    return -1;
80105fa2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fa7:	e9 61 01 00 00       	jmp    8010610d <sys_open+0x19b>

  begin_op();
80105fac:	e8 a5 d5 ff ff       	call   80103556 <begin_op>

  if(omode & O_CREATE){
80105fb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fb4:	25 00 02 00 00       	and    $0x200,%eax
80105fb9:	85 c0                	test   %eax,%eax
80105fbb:	74 2a                	je     80105fe7 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105fbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fc0:	6a 00                	push   $0x0
80105fc2:	6a 00                	push   $0x0
80105fc4:	6a 02                	push   $0x2
80105fc6:	50                   	push   %eax
80105fc7:	e8 d4 fd ff ff       	call   80105da0 <create>
80105fcc:	83 c4 10             	add    $0x10,%esp
80105fcf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105fd2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fd6:	75 75                	jne    8010604d <sys_open+0xdb>
      end_op();
80105fd8:	e8 05 d6 ff ff       	call   801035e2 <end_op>
      return -1;
80105fdd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fe2:	e9 26 01 00 00       	jmp    8010610d <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105fe7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fea:	83 ec 0c             	sub    $0xc,%esp
80105fed:	50                   	push   %eax
80105fee:	e8 47 c5 ff ff       	call   8010253a <namei>
80105ff3:	83 c4 10             	add    $0x10,%esp
80105ff6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ff9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ffd:	75 0f                	jne    8010600e <sys_open+0x9c>
      end_op();
80105fff:	e8 de d5 ff ff       	call   801035e2 <end_op>
      return -1;
80106004:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106009:	e9 ff 00 00 00       	jmp    8010610d <sys_open+0x19b>
    }
    ilock(ip);
8010600e:	83 ec 0c             	sub    $0xc,%esp
80106011:	ff 75 f4             	push   -0xc(%ebp)
80106014:	e8 70 b9 ff ff       	call   80101989 <ilock>
80106019:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010601c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010601f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106023:	66 83 f8 01          	cmp    $0x1,%ax
80106027:	75 24                	jne    8010604d <sys_open+0xdb>
80106029:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010602c:	85 c0                	test   %eax,%eax
8010602e:	74 1d                	je     8010604d <sys_open+0xdb>
      iunlockput(ip);
80106030:	83 ec 0c             	sub    $0xc,%esp
80106033:	ff 75 f4             	push   -0xc(%ebp)
80106036:	e8 0e bc ff ff       	call   80101c49 <iunlockput>
8010603b:	83 c4 10             	add    $0x10,%esp
      end_op();
8010603e:	e8 9f d5 ff ff       	call   801035e2 <end_op>
      return -1;
80106043:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106048:	e9 c0 00 00 00       	jmp    8010610d <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010604d:	e8 72 af ff ff       	call   80100fc4 <filealloc>
80106052:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106055:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106059:	74 17                	je     80106072 <sys_open+0x100>
8010605b:	83 ec 0c             	sub    $0xc,%esp
8010605e:	ff 75 f0             	push   -0x10(%ebp)
80106061:	e8 34 f7 ff ff       	call   8010579a <fdalloc>
80106066:	83 c4 10             	add    $0x10,%esp
80106069:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010606c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106070:	79 2e                	jns    801060a0 <sys_open+0x12e>
    if(f)
80106072:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106076:	74 0e                	je     80106086 <sys_open+0x114>
      fileclose(f);
80106078:	83 ec 0c             	sub    $0xc,%esp
8010607b:	ff 75 f0             	push   -0x10(%ebp)
8010607e:	e8 ff af ff ff       	call   80101082 <fileclose>
80106083:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106086:	83 ec 0c             	sub    $0xc,%esp
80106089:	ff 75 f4             	push   -0xc(%ebp)
8010608c:	e8 b8 bb ff ff       	call   80101c49 <iunlockput>
80106091:	83 c4 10             	add    $0x10,%esp
    end_op();
80106094:	e8 49 d5 ff ff       	call   801035e2 <end_op>
    return -1;
80106099:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010609e:	eb 6d                	jmp    8010610d <sys_open+0x19b>
  }
  iunlock(ip);
801060a0:	83 ec 0c             	sub    $0xc,%esp
801060a3:	ff 75 f4             	push   -0xc(%ebp)
801060a6:	e8 3c ba ff ff       	call   80101ae7 <iunlock>
801060ab:	83 c4 10             	add    $0x10,%esp
  end_op();
801060ae:	e8 2f d5 ff ff       	call   801035e2 <end_op>

  f->type = FD_INODE;
801060b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b6:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801060bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060c2:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801060c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c8:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801060cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060d2:	83 e0 01             	and    $0x1,%eax
801060d5:	85 c0                	test   %eax,%eax
801060d7:	0f 94 c0             	sete   %al
801060da:	89 c2                	mov    %eax,%edx
801060dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060df:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801060e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060e5:	83 e0 01             	and    $0x1,%eax
801060e8:	85 c0                	test   %eax,%eax
801060ea:	75 0a                	jne    801060f6 <sys_open+0x184>
801060ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060ef:	83 e0 02             	and    $0x2,%eax
801060f2:	85 c0                	test   %eax,%eax
801060f4:	74 07                	je     801060fd <sys_open+0x18b>
801060f6:	b8 01 00 00 00       	mov    $0x1,%eax
801060fb:	eb 05                	jmp    80106102 <sys_open+0x190>
801060fd:	b8 00 00 00 00       	mov    $0x0,%eax
80106102:	89 c2                	mov    %eax,%edx
80106104:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106107:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010610a:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010610d:	c9                   	leave
8010610e:	c3                   	ret

8010610f <sys_mkdir>:

int
sys_mkdir(void)
{
8010610f:	55                   	push   %ebp
80106110:	89 e5                	mov    %esp,%ebp
80106112:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106115:	e8 3c d4 ff ff       	call   80103556 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010611a:	83 ec 08             	sub    $0x8,%esp
8010611d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106120:	50                   	push   %eax
80106121:	6a 00                	push   $0x0
80106123:	e8 47 f5 ff ff       	call   8010566f <argstr>
80106128:	83 c4 10             	add    $0x10,%esp
8010612b:	85 c0                	test   %eax,%eax
8010612d:	78 1b                	js     8010614a <sys_mkdir+0x3b>
8010612f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106132:	6a 00                	push   $0x0
80106134:	6a 00                	push   $0x0
80106136:	6a 01                	push   $0x1
80106138:	50                   	push   %eax
80106139:	e8 62 fc ff ff       	call   80105da0 <create>
8010613e:	83 c4 10             	add    $0x10,%esp
80106141:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106144:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106148:	75 0c                	jne    80106156 <sys_mkdir+0x47>
    end_op();
8010614a:	e8 93 d4 ff ff       	call   801035e2 <end_op>
    return -1;
8010614f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106154:	eb 18                	jmp    8010616e <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106156:	83 ec 0c             	sub    $0xc,%esp
80106159:	ff 75 f4             	push   -0xc(%ebp)
8010615c:	e8 e8 ba ff ff       	call   80101c49 <iunlockput>
80106161:	83 c4 10             	add    $0x10,%esp
  end_op();
80106164:	e8 79 d4 ff ff       	call   801035e2 <end_op>
  return 0;
80106169:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010616e:	c9                   	leave
8010616f:	c3                   	ret

80106170 <sys_mknod>:

int
sys_mknod(void)
{
80106170:	55                   	push   %ebp
80106171:	89 e5                	mov    %esp,%ebp
80106173:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106176:	e8 db d3 ff ff       	call   80103556 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
8010617b:	83 ec 08             	sub    $0x8,%esp
8010617e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106181:	50                   	push   %eax
80106182:	6a 00                	push   $0x0
80106184:	e8 e6 f4 ff ff       	call   8010566f <argstr>
80106189:	83 c4 10             	add    $0x10,%esp
8010618c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010618f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106193:	78 4f                	js     801061e4 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106195:	83 ec 08             	sub    $0x8,%esp
80106198:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010619b:	50                   	push   %eax
8010619c:	6a 01                	push   $0x1
8010619e:	e8 47 f4 ff ff       	call   801055ea <argint>
801061a3:	83 c4 10             	add    $0x10,%esp
  if((len=argstr(0, &path)) < 0 ||
801061a6:	85 c0                	test   %eax,%eax
801061a8:	78 3a                	js     801061e4 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
801061aa:	83 ec 08             	sub    $0x8,%esp
801061ad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061b0:	50                   	push   %eax
801061b1:	6a 02                	push   $0x2
801061b3:	e8 32 f4 ff ff       	call   801055ea <argint>
801061b8:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801061bb:	85 c0                	test   %eax,%eax
801061bd:	78 25                	js     801061e4 <sys_mknod+0x74>
     (ip = create(path, T_DEV, major, minor)) == 0){
801061bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061c2:	0f bf c8             	movswl %ax,%ecx
801061c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061c8:	0f bf d0             	movswl %ax,%edx
801061cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061ce:	51                   	push   %ecx
801061cf:	52                   	push   %edx
801061d0:	6a 03                	push   $0x3
801061d2:	50                   	push   %eax
801061d3:	e8 c8 fb ff ff       	call   80105da0 <create>
801061d8:	83 c4 10             	add    $0x10,%esp
801061db:	89 45 f0             	mov    %eax,-0x10(%ebp)
     argint(2, &minor) < 0 ||
801061de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061e2:	75 0c                	jne    801061f0 <sys_mknod+0x80>
    end_op();
801061e4:	e8 f9 d3 ff ff       	call   801035e2 <end_op>
    return -1;
801061e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061ee:	eb 18                	jmp    80106208 <sys_mknod+0x98>
  }
  iunlockput(ip);
801061f0:	83 ec 0c             	sub    $0xc,%esp
801061f3:	ff 75 f0             	push   -0x10(%ebp)
801061f6:	e8 4e ba ff ff       	call   80101c49 <iunlockput>
801061fb:	83 c4 10             	add    $0x10,%esp
  end_op();
801061fe:	e8 df d3 ff ff       	call   801035e2 <end_op>
  return 0;
80106203:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106208:	c9                   	leave
80106209:	c3                   	ret

8010620a <sys_chdir>:

int
sys_chdir(void)
{
8010620a:	55                   	push   %ebp
8010620b:	89 e5                	mov    %esp,%ebp
8010620d:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106210:	e8 41 d3 ff ff       	call   80103556 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106215:	83 ec 08             	sub    $0x8,%esp
80106218:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010621b:	50                   	push   %eax
8010621c:	6a 00                	push   $0x0
8010621e:	e8 4c f4 ff ff       	call   8010566f <argstr>
80106223:	83 c4 10             	add    $0x10,%esp
80106226:	85 c0                	test   %eax,%eax
80106228:	78 18                	js     80106242 <sys_chdir+0x38>
8010622a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010622d:	83 ec 0c             	sub    $0xc,%esp
80106230:	50                   	push   %eax
80106231:	e8 04 c3 ff ff       	call   8010253a <namei>
80106236:	83 c4 10             	add    $0x10,%esp
80106239:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010623c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106240:	75 0c                	jne    8010624e <sys_chdir+0x44>
    end_op();
80106242:	e8 9b d3 ff ff       	call   801035e2 <end_op>
    return -1;
80106247:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010624c:	eb 6e                	jmp    801062bc <sys_chdir+0xb2>
  }
  ilock(ip);
8010624e:	83 ec 0c             	sub    $0xc,%esp
80106251:	ff 75 f4             	push   -0xc(%ebp)
80106254:	e8 30 b7 ff ff       	call   80101989 <ilock>
80106259:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010625c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010625f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106263:	66 83 f8 01          	cmp    $0x1,%ax
80106267:	74 1a                	je     80106283 <sys_chdir+0x79>
    iunlockput(ip);
80106269:	83 ec 0c             	sub    $0xc,%esp
8010626c:	ff 75 f4             	push   -0xc(%ebp)
8010626f:	e8 d5 b9 ff ff       	call   80101c49 <iunlockput>
80106274:	83 c4 10             	add    $0x10,%esp
    end_op();
80106277:	e8 66 d3 ff ff       	call   801035e2 <end_op>
    return -1;
8010627c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106281:	eb 39                	jmp    801062bc <sys_chdir+0xb2>
  }
  iunlock(ip);
80106283:	83 ec 0c             	sub    $0xc,%esp
80106286:	ff 75 f4             	push   -0xc(%ebp)
80106289:	e8 59 b8 ff ff       	call   80101ae7 <iunlock>
8010628e:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106291:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106297:	8b 40 68             	mov    0x68(%eax),%eax
8010629a:	83 ec 0c             	sub    $0xc,%esp
8010629d:	50                   	push   %eax
8010629e:	e8 b6 b8 ff ff       	call   80101b59 <iput>
801062a3:	83 c4 10             	add    $0x10,%esp
  end_op();
801062a6:	e8 37 d3 ff ff       	call   801035e2 <end_op>
  proc->cwd = ip;
801062ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062b4:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801062b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062bc:	c9                   	leave
801062bd:	c3                   	ret

801062be <sys_exec>:

int
sys_exec(void)
{
801062be:	55                   	push   %ebp
801062bf:	89 e5                	mov    %esp,%ebp
801062c1:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801062c7:	83 ec 08             	sub    $0x8,%esp
801062ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062cd:	50                   	push   %eax
801062ce:	6a 00                	push   $0x0
801062d0:	e8 9a f3 ff ff       	call   8010566f <argstr>
801062d5:	83 c4 10             	add    $0x10,%esp
801062d8:	85 c0                	test   %eax,%eax
801062da:	78 18                	js     801062f4 <sys_exec+0x36>
801062dc:	83 ec 08             	sub    $0x8,%esp
801062df:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801062e5:	50                   	push   %eax
801062e6:	6a 01                	push   $0x1
801062e8:	e8 fd f2 ff ff       	call   801055ea <argint>
801062ed:	83 c4 10             	add    $0x10,%esp
801062f0:	85 c0                	test   %eax,%eax
801062f2:	79 0a                	jns    801062fe <sys_exec+0x40>
    return -1;
801062f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f9:	e9 c6 00 00 00       	jmp    801063c4 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
801062fe:	83 ec 04             	sub    $0x4,%esp
80106301:	68 80 00 00 00       	push   $0x80
80106306:	6a 00                	push   $0x0
80106308:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010630e:	50                   	push   %eax
8010630f:	e8 b2 ef ff ff       	call   801052c6 <memset>
80106314:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106317:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010631e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106321:	83 f8 1f             	cmp    $0x1f,%eax
80106324:	76 0a                	jbe    80106330 <sys_exec+0x72>
      return -1;
80106326:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010632b:	e9 94 00 00 00       	jmp    801063c4 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106333:	c1 e0 02             	shl    $0x2,%eax
80106336:	89 c2                	mov    %eax,%edx
80106338:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010633e:	01 c2                	add    %eax,%edx
80106340:	83 ec 08             	sub    $0x8,%esp
80106343:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106349:	50                   	push   %eax
8010634a:	52                   	push   %edx
8010634b:	e8 00 f2 ff ff       	call   80105550 <fetchint>
80106350:	83 c4 10             	add    $0x10,%esp
80106353:	85 c0                	test   %eax,%eax
80106355:	79 07                	jns    8010635e <sys_exec+0xa0>
      return -1;
80106357:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010635c:	eb 66                	jmp    801063c4 <sys_exec+0x106>
    if(uarg == 0){
8010635e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106364:	85 c0                	test   %eax,%eax
80106366:	75 27                	jne    8010638f <sys_exec+0xd1>
      argv[i] = 0;
80106368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010636b:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106372:	00 00 00 00 
      break;
80106376:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106377:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010637a:	83 ec 08             	sub    $0x8,%esp
8010637d:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106383:	52                   	push   %edx
80106384:	50                   	push   %eax
80106385:	e8 18 a8 ff ff       	call   80100ba2 <exec>
8010638a:	83 c4 10             	add    $0x10,%esp
8010638d:	eb 35                	jmp    801063c4 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
8010638f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106395:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106398:	c1 e2 02             	shl    $0x2,%edx
8010639b:	01 c2                	add    %eax,%edx
8010639d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801063a3:	83 ec 08             	sub    $0x8,%esp
801063a6:	52                   	push   %edx
801063a7:	50                   	push   %eax
801063a8:	e8 dd f1 ff ff       	call   8010558a <fetchstr>
801063ad:	83 c4 10             	add    $0x10,%esp
801063b0:	85 c0                	test   %eax,%eax
801063b2:	79 07                	jns    801063bb <sys_exec+0xfd>
      return -1;
801063b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b9:	eb 09                	jmp    801063c4 <sys_exec+0x106>
  for(i=0;; i++){
801063bb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801063bf:	e9 5a ff ff ff       	jmp    8010631e <sys_exec+0x60>
}
801063c4:	c9                   	leave
801063c5:	c3                   	ret

801063c6 <sys_pipe>:

int
sys_pipe(void)
{
801063c6:	55                   	push   %ebp
801063c7:	89 e5                	mov    %esp,%ebp
801063c9:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801063cc:	83 ec 04             	sub    $0x4,%esp
801063cf:	6a 08                	push   $0x8
801063d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063d4:	50                   	push   %eax
801063d5:	6a 00                	push   $0x0
801063d7:	e8 36 f2 ff ff       	call   80105612 <argptr>
801063dc:	83 c4 10             	add    $0x10,%esp
801063df:	85 c0                	test   %eax,%eax
801063e1:	79 0a                	jns    801063ed <sys_pipe+0x27>
    return -1;
801063e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063e8:	e9 af 00 00 00       	jmp    8010649c <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
801063ed:	83 ec 08             	sub    $0x8,%esp
801063f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801063f3:	50                   	push   %eax
801063f4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801063f7:	50                   	push   %eax
801063f8:	e8 84 dc ff ff       	call   80104081 <pipealloc>
801063fd:	83 c4 10             	add    $0x10,%esp
80106400:	85 c0                	test   %eax,%eax
80106402:	79 0a                	jns    8010640e <sys_pipe+0x48>
    return -1;
80106404:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106409:	e9 8e 00 00 00       	jmp    8010649c <sys_pipe+0xd6>
  fd0 = -1;
8010640e:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106415:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106418:	83 ec 0c             	sub    $0xc,%esp
8010641b:	50                   	push   %eax
8010641c:	e8 79 f3 ff ff       	call   8010579a <fdalloc>
80106421:	83 c4 10             	add    $0x10,%esp
80106424:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106427:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010642b:	78 18                	js     80106445 <sys_pipe+0x7f>
8010642d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106430:	83 ec 0c             	sub    $0xc,%esp
80106433:	50                   	push   %eax
80106434:	e8 61 f3 ff ff       	call   8010579a <fdalloc>
80106439:	83 c4 10             	add    $0x10,%esp
8010643c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010643f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106443:	79 3f                	jns    80106484 <sys_pipe+0xbe>
    if(fd0 >= 0)
80106445:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106449:	78 14                	js     8010645f <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
8010644b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106451:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106454:	83 c2 08             	add    $0x8,%edx
80106457:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010645e:	00 
    fileclose(rf);
8010645f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106462:	83 ec 0c             	sub    $0xc,%esp
80106465:	50                   	push   %eax
80106466:	e8 17 ac ff ff       	call   80101082 <fileclose>
8010646b:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010646e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106471:	83 ec 0c             	sub    $0xc,%esp
80106474:	50                   	push   %eax
80106475:	e8 08 ac ff ff       	call   80101082 <fileclose>
8010647a:	83 c4 10             	add    $0x10,%esp
    return -1;
8010647d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106482:	eb 18                	jmp    8010649c <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80106484:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106487:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010648a:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010648c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010648f:	8d 50 04             	lea    0x4(%eax),%edx
80106492:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106495:	89 02                	mov    %eax,(%edx)
  return 0;
80106497:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010649c:	c9                   	leave
8010649d:	c3                   	ret

8010649e <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010649e:	55                   	push   %ebp
8010649f:	89 e5                	mov    %esp,%ebp
801064a1:	83 ec 08             	sub    $0x8,%esp
  return fork();
801064a4:	e8 cf e2 ff ff       	call   80104778 <fork>
}
801064a9:	c9                   	leave
801064aa:	c3                   	ret

801064ab <sys_exit>:

int
sys_exit(void)
{
801064ab:	55                   	push   %ebp
801064ac:	89 e5                	mov    %esp,%ebp
801064ae:	83 ec 08             	sub    $0x8,%esp
  exit();
801064b1:	e8 4f e4 ff ff       	call   80104905 <exit>
  return 0;  // not reached
801064b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064bb:	c9                   	leave
801064bc:	c3                   	ret

801064bd <sys_wait>:

int
sys_wait(void)
{
801064bd:	55                   	push   %ebp
801064be:	89 e5                	mov    %esp,%ebp
801064c0:	83 ec 08             	sub    $0x8,%esp
  return wait();
801064c3:	e8 75 e5 ff ff       	call   80104a3d <wait>
}
801064c8:	c9                   	leave
801064c9:	c3                   	ret

801064ca <sys_kill>:

int
sys_kill(void)
{
801064ca:	55                   	push   %ebp
801064cb:	89 e5                	mov    %esp,%ebp
801064cd:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801064d0:	83 ec 08             	sub    $0x8,%esp
801064d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064d6:	50                   	push   %eax
801064d7:	6a 00                	push   $0x0
801064d9:	e8 0c f1 ff ff       	call   801055ea <argint>
801064de:	83 c4 10             	add    $0x10,%esp
801064e1:	85 c0                	test   %eax,%eax
801064e3:	79 07                	jns    801064ec <sys_kill+0x22>
    return -1;
801064e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ea:	eb 0f                	jmp    801064fb <sys_kill+0x31>
  return kill(pid);
801064ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ef:	83 ec 0c             	sub    $0xc,%esp
801064f2:	50                   	push   %eax
801064f3:	e8 92 e9 ff ff       	call   80104e8a <kill>
801064f8:	83 c4 10             	add    $0x10,%esp
}
801064fb:	c9                   	leave
801064fc:	c3                   	ret

801064fd <sys_getpid>:

int
sys_getpid(void)
{
801064fd:	55                   	push   %ebp
801064fe:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106500:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106506:	8b 40 10             	mov    0x10(%eax),%eax
}
80106509:	5d                   	pop    %ebp
8010650a:	c3                   	ret

8010650b <sys_sbrk>:

int
sys_sbrk(void)
{
8010650b:	55                   	push   %ebp
8010650c:	89 e5                	mov    %esp,%ebp
8010650e:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106511:	83 ec 08             	sub    $0x8,%esp
80106514:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106517:	50                   	push   %eax
80106518:	6a 00                	push   $0x0
8010651a:	e8 cb f0 ff ff       	call   801055ea <argint>
8010651f:	83 c4 10             	add    $0x10,%esp
80106522:	85 c0                	test   %eax,%eax
80106524:	79 07                	jns    8010652d <sys_sbrk+0x22>
    return -1;
80106526:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010652b:	eb 28                	jmp    80106555 <sys_sbrk+0x4a>
  addr = proc->sz;
8010652d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106533:	8b 00                	mov    (%eax),%eax
80106535:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106538:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010653b:	83 ec 0c             	sub    $0xc,%esp
8010653e:	50                   	push   %eax
8010653f:	e8 91 e1 ff ff       	call   801046d5 <growproc>
80106544:	83 c4 10             	add    $0x10,%esp
80106547:	85 c0                	test   %eax,%eax
80106549:	79 07                	jns    80106552 <sys_sbrk+0x47>
    return -1;
8010654b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106550:	eb 03                	jmp    80106555 <sys_sbrk+0x4a>
  return addr;
80106552:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106555:	c9                   	leave
80106556:	c3                   	ret

80106557 <sys_sleep>:

int
sys_sleep(void)
{
80106557:	55                   	push   %ebp
80106558:	89 e5                	mov    %esp,%ebp
8010655a:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
8010655d:	83 ec 08             	sub    $0x8,%esp
80106560:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106563:	50                   	push   %eax
80106564:	6a 00                	push   $0x0
80106566:	e8 7f f0 ff ff       	call   801055ea <argint>
8010656b:	83 c4 10             	add    $0x10,%esp
8010656e:	85 c0                	test   %eax,%eax
80106570:	79 07                	jns    80106579 <sys_sleep+0x22>
    return -1;
80106572:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106577:	eb 77                	jmp    801065f0 <sys_sleep+0x99>
  acquire(&tickslock);
80106579:	83 ec 0c             	sub    $0xc,%esp
8010657c:	68 60 40 11 80       	push   $0x80114060
80106581:	e8 dc ea ff ff       	call   80105062 <acquire>
80106586:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106589:	a1 94 40 11 80       	mov    0x80114094,%eax
8010658e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106591:	eb 39                	jmp    801065cc <sys_sleep+0x75>
    if(proc->killed){
80106593:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106599:	8b 40 24             	mov    0x24(%eax),%eax
8010659c:	85 c0                	test   %eax,%eax
8010659e:	74 17                	je     801065b7 <sys_sleep+0x60>
      release(&tickslock);
801065a0:	83 ec 0c             	sub    $0xc,%esp
801065a3:	68 60 40 11 80       	push   $0x80114060
801065a8:	e8 1c eb ff ff       	call   801050c9 <release>
801065ad:	83 c4 10             	add    $0x10,%esp
      return -1;
801065b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065b5:	eb 39                	jmp    801065f0 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
801065b7:	83 ec 08             	sub    $0x8,%esp
801065ba:	68 60 40 11 80       	push   $0x80114060
801065bf:	68 94 40 11 80       	push   $0x80114094
801065c4:	e8 9e e7 ff ff       	call   80104d67 <sleep>
801065c9:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801065cc:	a1 94 40 11 80       	mov    0x80114094,%eax
801065d1:	2b 45 f4             	sub    -0xc(%ebp),%eax
801065d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065d7:	39 d0                	cmp    %edx,%eax
801065d9:	72 b8                	jb     80106593 <sys_sleep+0x3c>
  }
  release(&tickslock);
801065db:	83 ec 0c             	sub    $0xc,%esp
801065de:	68 60 40 11 80       	push   $0x80114060
801065e3:	e8 e1 ea ff ff       	call   801050c9 <release>
801065e8:	83 c4 10             	add    $0x10,%esp
  return 0;
801065eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065f0:	c9                   	leave
801065f1:	c3                   	ret

801065f2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801065f2:	55                   	push   %ebp
801065f3:	89 e5                	mov    %esp,%ebp
801065f5:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
801065f8:	83 ec 0c             	sub    $0xc,%esp
801065fb:	68 60 40 11 80       	push   $0x80114060
80106600:	e8 5d ea ff ff       	call   80105062 <acquire>
80106605:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106608:	a1 94 40 11 80       	mov    0x80114094,%eax
8010660d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106610:	83 ec 0c             	sub    $0xc,%esp
80106613:	68 60 40 11 80       	push   $0x80114060
80106618:	e8 ac ea ff ff       	call   801050c9 <release>
8010661d:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106620:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106623:	c9                   	leave
80106624:	c3                   	ret

80106625 <outb>:
{
80106625:	55                   	push   %ebp
80106626:	89 e5                	mov    %esp,%ebp
80106628:	83 ec 08             	sub    $0x8,%esp
8010662b:	8b 55 08             	mov    0x8(%ebp),%edx
8010662e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106631:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106635:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106638:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010663c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106640:	ee                   	out    %al,(%dx)
}
80106641:	90                   	nop
80106642:	c9                   	leave
80106643:	c3                   	ret

80106644 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106644:	55                   	push   %ebp
80106645:	89 e5                	mov    %esp,%ebp
80106647:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010664a:	6a 34                	push   $0x34
8010664c:	6a 43                	push   $0x43
8010664e:	e8 d2 ff ff ff       	call   80106625 <outb>
80106653:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106656:	68 9c 00 00 00       	push   $0x9c
8010665b:	6a 40                	push   $0x40
8010665d:	e8 c3 ff ff ff       	call   80106625 <outb>
80106662:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106665:	6a 2e                	push   $0x2e
80106667:	6a 40                	push   $0x40
80106669:	e8 b7 ff ff ff       	call   80106625 <outb>
8010666e:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80106671:	83 ec 0c             	sub    $0xc,%esp
80106674:	6a 00                	push   $0x0
80106676:	e8 f0 d8 ff ff       	call   80103f6b <picenable>
8010667b:	83 c4 10             	add    $0x10,%esp
}
8010667e:	90                   	nop
8010667f:	c9                   	leave
80106680:	c3                   	ret

80106681 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106681:	1e                   	push   %ds
  pushl %es
80106682:	06                   	push   %es
  pushl %fs
80106683:	0f a0                	push   %fs
  pushl %gs
80106685:	0f a8                	push   %gs
  pushal
80106687:	60                   	pusha
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106688:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010668c:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010668e:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106690:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106694:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106696:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106698:	54                   	push   %esp
  call trap
80106699:	e8 d7 01 00 00       	call   80106875 <trap>
  addl $4, %esp
8010669e:	83 c4 04             	add    $0x4,%esp

801066a1 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801066a1:	61                   	popa
  popl %gs
801066a2:	0f a9                	pop    %gs
  popl %fs
801066a4:	0f a1                	pop    %fs
  popl %es
801066a6:	07                   	pop    %es
  popl %ds
801066a7:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801066a8:	83 c4 08             	add    $0x8,%esp
  iret
801066ab:	cf                   	iret

801066ac <lidt>:
{
801066ac:	55                   	push   %ebp
801066ad:	89 e5                	mov    %esp,%ebp
801066af:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801066b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801066b5:	83 e8 01             	sub    $0x1,%eax
801066b8:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801066bc:	8b 45 08             	mov    0x8(%ebp),%eax
801066bf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801066c3:	8b 45 08             	mov    0x8(%ebp),%eax
801066c6:	c1 e8 10             	shr    $0x10,%eax
801066c9:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801066cd:	8d 45 fa             	lea    -0x6(%ebp),%eax
801066d0:	0f 01 18             	lidtl  (%eax)
}
801066d3:	90                   	nop
801066d4:	c9                   	leave
801066d5:	c3                   	ret

801066d6 <rcr2>:
{
801066d6:	55                   	push   %ebp
801066d7:	89 e5                	mov    %esp,%ebp
801066d9:	83 ec 10             	sub    $0x10,%esp
  asm volatile("movl %%cr2,%0" : "=r" (val));
801066dc:	0f 20 d0             	mov    %cr2,%eax
801066df:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801066e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801066e5:	c9                   	leave
801066e6:	c3                   	ret

801066e7 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801066e7:	55                   	push   %ebp
801066e8:	89 e5                	mov    %esp,%ebp
801066ea:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801066ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801066f4:	e9 c3 00 00 00       	jmp    801067bc <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801066f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066fc:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
80106703:	89 c2                	mov    %eax,%edx
80106705:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106708:	66 89 14 c5 60 38 11 	mov    %dx,-0x7feec7a0(,%eax,8)
8010670f:	80 
80106710:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106713:	66 c7 04 c5 62 38 11 	movw   $0x8,-0x7feec79e(,%eax,8)
8010671a:	80 08 00 
8010671d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106720:	0f b6 14 c5 64 38 11 	movzbl -0x7feec79c(,%eax,8),%edx
80106727:	80 
80106728:	83 e2 e0             	and    $0xffffffe0,%edx
8010672b:	88 14 c5 64 38 11 80 	mov    %dl,-0x7feec79c(,%eax,8)
80106732:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106735:	0f b6 14 c5 64 38 11 	movzbl -0x7feec79c(,%eax,8),%edx
8010673c:	80 
8010673d:	83 e2 1f             	and    $0x1f,%edx
80106740:	88 14 c5 64 38 11 80 	mov    %dl,-0x7feec79c(,%eax,8)
80106747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010674a:	0f b6 14 c5 65 38 11 	movzbl -0x7feec79b(,%eax,8),%edx
80106751:	80 
80106752:	83 e2 f0             	and    $0xfffffff0,%edx
80106755:	83 ca 0e             	or     $0xe,%edx
80106758:	88 14 c5 65 38 11 80 	mov    %dl,-0x7feec79b(,%eax,8)
8010675f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106762:	0f b6 14 c5 65 38 11 	movzbl -0x7feec79b(,%eax,8),%edx
80106769:	80 
8010676a:	83 e2 ef             	and    $0xffffffef,%edx
8010676d:	88 14 c5 65 38 11 80 	mov    %dl,-0x7feec79b(,%eax,8)
80106774:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106777:	0f b6 14 c5 65 38 11 	movzbl -0x7feec79b(,%eax,8),%edx
8010677e:	80 
8010677f:	83 e2 9f             	and    $0xffffff9f,%edx
80106782:	88 14 c5 65 38 11 80 	mov    %dl,-0x7feec79b(,%eax,8)
80106789:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010678c:	0f b6 14 c5 65 38 11 	movzbl -0x7feec79b(,%eax,8),%edx
80106793:	80 
80106794:	83 ca 80             	or     $0xffffff80,%edx
80106797:	88 14 c5 65 38 11 80 	mov    %dl,-0x7feec79b(,%eax,8)
8010679e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a1:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
801067a8:	c1 e8 10             	shr    $0x10,%eax
801067ab:	89 c2                	mov    %eax,%edx
801067ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067b0:	66 89 14 c5 66 38 11 	mov    %dx,-0x7feec79a(,%eax,8)
801067b7:	80 
  for(i = 0; i < 256; i++)
801067b8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067bc:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801067c3:	0f 8e 30 ff ff ff    	jle    801066f9 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801067c9:	a1 98 b1 10 80       	mov    0x8010b198,%eax
801067ce:	66 a3 60 3a 11 80    	mov    %ax,0x80113a60
801067d4:	66 c7 05 62 3a 11 80 	movw   $0x8,0x80113a62
801067db:	08 00 
801067dd:	0f b6 05 64 3a 11 80 	movzbl 0x80113a64,%eax
801067e4:	83 e0 e0             	and    $0xffffffe0,%eax
801067e7:	a2 64 3a 11 80       	mov    %al,0x80113a64
801067ec:	0f b6 05 64 3a 11 80 	movzbl 0x80113a64,%eax
801067f3:	83 e0 1f             	and    $0x1f,%eax
801067f6:	a2 64 3a 11 80       	mov    %al,0x80113a64
801067fb:	0f b6 05 65 3a 11 80 	movzbl 0x80113a65,%eax
80106802:	83 c8 0f             	or     $0xf,%eax
80106805:	a2 65 3a 11 80       	mov    %al,0x80113a65
8010680a:	0f b6 05 65 3a 11 80 	movzbl 0x80113a65,%eax
80106811:	83 e0 ef             	and    $0xffffffef,%eax
80106814:	a2 65 3a 11 80       	mov    %al,0x80113a65
80106819:	0f b6 05 65 3a 11 80 	movzbl 0x80113a65,%eax
80106820:	83 c8 60             	or     $0x60,%eax
80106823:	a2 65 3a 11 80       	mov    %al,0x80113a65
80106828:	0f b6 05 65 3a 11 80 	movzbl 0x80113a65,%eax
8010682f:	83 c8 80             	or     $0xffffff80,%eax
80106832:	a2 65 3a 11 80       	mov    %al,0x80113a65
80106837:	a1 98 b1 10 80       	mov    0x8010b198,%eax
8010683c:	c1 e8 10             	shr    $0x10,%eax
8010683f:	66 a3 66 3a 11 80    	mov    %ax,0x80113a66
  
  initlock(&tickslock, "time");
80106845:	83 ec 08             	sub    $0x8,%esp
80106848:	68 70 8a 10 80       	push   $0x80108a70
8010684d:	68 60 40 11 80       	push   $0x80114060
80106852:	e8 e9 e7 ff ff       	call   80105040 <initlock>
80106857:	83 c4 10             	add    $0x10,%esp
}
8010685a:	90                   	nop
8010685b:	c9                   	leave
8010685c:	c3                   	ret

8010685d <idtinit>:

void
idtinit(void)
{
8010685d:	55                   	push   %ebp
8010685e:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106860:	68 00 08 00 00       	push   $0x800
80106865:	68 60 38 11 80       	push   $0x80113860
8010686a:	e8 3d fe ff ff       	call   801066ac <lidt>
8010686f:	83 c4 08             	add    $0x8,%esp
}
80106872:	90                   	nop
80106873:	c9                   	leave
80106874:	c3                   	ret

80106875 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106875:	55                   	push   %ebp
80106876:	89 e5                	mov    %esp,%ebp
80106878:	57                   	push   %edi
80106879:	56                   	push   %esi
8010687a:	53                   	push   %ebx
8010687b:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
8010687e:	8b 45 08             	mov    0x8(%ebp),%eax
80106881:	8b 40 30             	mov    0x30(%eax),%eax
80106884:	83 f8 40             	cmp    $0x40,%eax
80106887:	75 3e                	jne    801068c7 <trap+0x52>
    if(proc->killed)
80106889:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010688f:	8b 40 24             	mov    0x24(%eax),%eax
80106892:	85 c0                	test   %eax,%eax
80106894:	74 05                	je     8010689b <trap+0x26>
      exit();
80106896:	e8 6a e0 ff ff       	call   80104905 <exit>
    proc->tf = tf;
8010689b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068a1:	8b 55 08             	mov    0x8(%ebp),%edx
801068a4:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801068a7:	e8 f4 ed ff ff       	call   801056a0 <syscall>
    if(proc->killed)
801068ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068b2:	8b 40 24             	mov    0x24(%eax),%eax
801068b5:	85 c0                	test   %eax,%eax
801068b7:	0f 84 1c 02 00 00    	je     80106ad9 <trap+0x264>
      exit();
801068bd:	e8 43 e0 ff ff       	call   80104905 <exit>
    return;
801068c2:	e9 12 02 00 00       	jmp    80106ad9 <trap+0x264>
  }

  switch(tf->trapno){
801068c7:	8b 45 08             	mov    0x8(%ebp),%eax
801068ca:	8b 40 30             	mov    0x30(%eax),%eax
801068cd:	83 e8 20             	sub    $0x20,%eax
801068d0:	83 f8 1f             	cmp    $0x1f,%eax
801068d3:	0f 87 c0 00 00 00    	ja     80106999 <trap+0x124>
801068d9:	8b 04 85 18 8b 10 80 	mov    -0x7fef74e8(,%eax,4),%eax
801068e0:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801068e2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801068e8:	0f b6 00             	movzbl (%eax),%eax
801068eb:	84 c0                	test   %al,%al
801068ed:	75 3d                	jne    8010692c <trap+0xb7>
      acquire(&tickslock);
801068ef:	83 ec 0c             	sub    $0xc,%esp
801068f2:	68 60 40 11 80       	push   $0x80114060
801068f7:	e8 66 e7 ff ff       	call   80105062 <acquire>
801068fc:	83 c4 10             	add    $0x10,%esp
      ticks++;
801068ff:	a1 94 40 11 80       	mov    0x80114094,%eax
80106904:	83 c0 01             	add    $0x1,%eax
80106907:	a3 94 40 11 80       	mov    %eax,0x80114094
      wakeup(&ticks);
8010690c:	83 ec 0c             	sub    $0xc,%esp
8010690f:	68 94 40 11 80       	push   $0x80114094
80106914:	e8 3a e5 ff ff       	call   80104e53 <wakeup>
80106919:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
8010691c:	83 ec 0c             	sub    $0xc,%esp
8010691f:	68 60 40 11 80       	push   $0x80114060
80106924:	e8 a0 e7 ff ff       	call   801050c9 <release>
80106929:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
8010692c:	e8 05 c7 ff ff       	call   80103036 <lapiceoi>
    break;
80106931:	e9 1d 01 00 00       	jmp    80106a53 <trap+0x1de>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106936:	e8 0f bf ff ff       	call   8010284a <ideintr>
    lapiceoi();
8010693b:	e8 f6 c6 ff ff       	call   80103036 <lapiceoi>
    break;
80106940:	e9 0e 01 00 00       	jmp    80106a53 <trap+0x1de>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106945:	e8 f0 c4 ff ff       	call   80102e3a <kbdintr>
    lapiceoi();
8010694a:	e8 e7 c6 ff ff       	call   80103036 <lapiceoi>
    break;
8010694f:	e9 ff 00 00 00       	jmp    80106a53 <trap+0x1de>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106954:	e8 61 03 00 00       	call   80106cba <uartintr>
    lapiceoi();
80106959:	e8 d8 c6 ff ff       	call   80103036 <lapiceoi>
    break;
8010695e:	e9 f0 00 00 00       	jmp    80106a53 <trap+0x1de>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106963:	8b 45 08             	mov    0x8(%ebp),%eax
80106966:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106969:	8b 45 08             	mov    0x8(%ebp),%eax
8010696c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106970:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106973:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106979:	0f b6 00             	movzbl (%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010697c:	0f b6 c0             	movzbl %al,%eax
8010697f:	51                   	push   %ecx
80106980:	52                   	push   %edx
80106981:	50                   	push   %eax
80106982:	68 78 8a 10 80       	push   $0x80108a78
80106987:	e8 38 9a ff ff       	call   801003c4 <cprintf>
8010698c:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
8010698f:	e8 a2 c6 ff ff       	call   80103036 <lapiceoi>
    break;
80106994:	e9 ba 00 00 00       	jmp    80106a53 <trap+0x1de>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106999:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010699f:	85 c0                	test   %eax,%eax
801069a1:	74 11                	je     801069b4 <trap+0x13f>
801069a3:	8b 45 08             	mov    0x8(%ebp),%eax
801069a6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801069aa:	0f b7 c0             	movzwl %ax,%eax
801069ad:	83 e0 03             	and    $0x3,%eax
801069b0:	85 c0                	test   %eax,%eax
801069b2:	75 3f                	jne    801069f3 <trap+0x17e>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801069b4:	e8 1d fd ff ff       	call   801066d6 <rcr2>
801069b9:	8b 55 08             	mov    0x8(%ebp),%edx
801069bc:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
801069bf:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801069c6:	0f b6 12             	movzbl (%edx),%edx
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801069c9:	0f b6 ca             	movzbl %dl,%ecx
801069cc:	8b 55 08             	mov    0x8(%ebp),%edx
801069cf:	8b 52 30             	mov    0x30(%edx),%edx
801069d2:	83 ec 0c             	sub    $0xc,%esp
801069d5:	50                   	push   %eax
801069d6:	53                   	push   %ebx
801069d7:	51                   	push   %ecx
801069d8:	52                   	push   %edx
801069d9:	68 9c 8a 10 80       	push   $0x80108a9c
801069de:	e8 e1 99 ff ff       	call   801003c4 <cprintf>
801069e3:	83 c4 20             	add    $0x20,%esp
      panic("trap");
801069e6:	83 ec 0c             	sub    $0xc,%esp
801069e9:	68 ce 8a 10 80       	push   $0x80108ace
801069ee:	e8 86 9b ff ff       	call   80100579 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069f3:	e8 de fc ff ff       	call   801066d6 <rcr2>
801069f8:	89 c2                	mov    %eax,%edx
801069fa:	8b 45 08             	mov    0x8(%ebp),%eax
801069fd:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106a00:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a06:	0f b6 00             	movzbl (%eax),%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a09:	0f b6 f0             	movzbl %al,%esi
80106a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80106a0f:	8b 58 34             	mov    0x34(%eax),%ebx
80106a12:	8b 45 08             	mov    0x8(%ebp),%eax
80106a15:	8b 48 30             	mov    0x30(%eax),%ecx
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106a18:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a1e:	83 c0 6c             	add    $0x6c,%eax
80106a21:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106a24:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a2a:	8b 40 10             	mov    0x10(%eax),%eax
80106a2d:	52                   	push   %edx
80106a2e:	57                   	push   %edi
80106a2f:	56                   	push   %esi
80106a30:	53                   	push   %ebx
80106a31:	51                   	push   %ecx
80106a32:	ff 75 e4             	push   -0x1c(%ebp)
80106a35:	50                   	push   %eax
80106a36:	68 d4 8a 10 80       	push   $0x80108ad4
80106a3b:	e8 84 99 ff ff       	call   801003c4 <cprintf>
80106a40:	83 c4 20             	add    $0x20,%esp
            rcr2());
    proc->killed = 1;
80106a43:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a49:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106a50:	eb 01                	jmp    80106a53 <trap+0x1de>
    break;
80106a52:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106a53:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a59:	85 c0                	test   %eax,%eax
80106a5b:	74 24                	je     80106a81 <trap+0x20c>
80106a5d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a63:	8b 40 24             	mov    0x24(%eax),%eax
80106a66:	85 c0                	test   %eax,%eax
80106a68:	74 17                	je     80106a81 <trap+0x20c>
80106a6a:	8b 45 08             	mov    0x8(%ebp),%eax
80106a6d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a71:	0f b7 c0             	movzwl %ax,%eax
80106a74:	83 e0 03             	and    $0x3,%eax
80106a77:	83 f8 03             	cmp    $0x3,%eax
80106a7a:	75 05                	jne    80106a81 <trap+0x20c>
    exit();
80106a7c:	e8 84 de ff ff       	call   80104905 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106a81:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a87:	85 c0                	test   %eax,%eax
80106a89:	74 1e                	je     80106aa9 <trap+0x234>
80106a8b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a91:	8b 40 0c             	mov    0xc(%eax),%eax
80106a94:	83 f8 04             	cmp    $0x4,%eax
80106a97:	75 10                	jne    80106aa9 <trap+0x234>
80106a99:	8b 45 08             	mov    0x8(%ebp),%eax
80106a9c:	8b 40 30             	mov    0x30(%eax),%eax
80106a9f:	83 f8 20             	cmp    $0x20,%eax
80106aa2:	75 05                	jne    80106aa9 <trap+0x234>
    yield();
80106aa4:	e8 3d e2 ff ff       	call   80104ce6 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106aa9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106aaf:	85 c0                	test   %eax,%eax
80106ab1:	74 27                	je     80106ada <trap+0x265>
80106ab3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ab9:	8b 40 24             	mov    0x24(%eax),%eax
80106abc:	85 c0                	test   %eax,%eax
80106abe:	74 1a                	je     80106ada <trap+0x265>
80106ac0:	8b 45 08             	mov    0x8(%ebp),%eax
80106ac3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ac7:	0f b7 c0             	movzwl %ax,%eax
80106aca:	83 e0 03             	and    $0x3,%eax
80106acd:	83 f8 03             	cmp    $0x3,%eax
80106ad0:	75 08                	jne    80106ada <trap+0x265>
    exit();
80106ad2:	e8 2e de ff ff       	call   80104905 <exit>
80106ad7:	eb 01                	jmp    80106ada <trap+0x265>
    return;
80106ad9:	90                   	nop
}
80106ada:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106add:	5b                   	pop    %ebx
80106ade:	5e                   	pop    %esi
80106adf:	5f                   	pop    %edi
80106ae0:	5d                   	pop    %ebp
80106ae1:	c3                   	ret

80106ae2 <inb>:
{
80106ae2:	55                   	push   %ebp
80106ae3:	89 e5                	mov    %esp,%ebp
80106ae5:	83 ec 14             	sub    $0x14,%esp
80106ae8:	8b 45 08             	mov    0x8(%ebp),%eax
80106aeb:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106aef:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106af3:	89 c2                	mov    %eax,%edx
80106af5:	ec                   	in     (%dx),%al
80106af6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106af9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106afd:	c9                   	leave
80106afe:	c3                   	ret

80106aff <outb>:
{
80106aff:	55                   	push   %ebp
80106b00:	89 e5                	mov    %esp,%ebp
80106b02:	83 ec 08             	sub    $0x8,%esp
80106b05:	8b 55 08             	mov    0x8(%ebp),%edx
80106b08:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b0b:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106b0f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106b12:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106b16:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106b1a:	ee                   	out    %al,(%dx)
}
80106b1b:	90                   	nop
80106b1c:	c9                   	leave
80106b1d:	c3                   	ret

80106b1e <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106b1e:	55                   	push   %ebp
80106b1f:	89 e5                	mov    %esp,%ebp
80106b21:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106b24:	6a 00                	push   $0x0
80106b26:	68 fa 03 00 00       	push   $0x3fa
80106b2b:	e8 cf ff ff ff       	call   80106aff <outb>
80106b30:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106b33:	68 80 00 00 00       	push   $0x80
80106b38:	68 fb 03 00 00       	push   $0x3fb
80106b3d:	e8 bd ff ff ff       	call   80106aff <outb>
80106b42:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106b45:	6a 0c                	push   $0xc
80106b47:	68 f8 03 00 00       	push   $0x3f8
80106b4c:	e8 ae ff ff ff       	call   80106aff <outb>
80106b51:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106b54:	6a 00                	push   $0x0
80106b56:	68 f9 03 00 00       	push   $0x3f9
80106b5b:	e8 9f ff ff ff       	call   80106aff <outb>
80106b60:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106b63:	6a 03                	push   $0x3
80106b65:	68 fb 03 00 00       	push   $0x3fb
80106b6a:	e8 90 ff ff ff       	call   80106aff <outb>
80106b6f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106b72:	6a 00                	push   $0x0
80106b74:	68 fc 03 00 00       	push   $0x3fc
80106b79:	e8 81 ff ff ff       	call   80106aff <outb>
80106b7e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106b81:	6a 01                	push   $0x1
80106b83:	68 f9 03 00 00       	push   $0x3f9
80106b88:	e8 72 ff ff ff       	call   80106aff <outb>
80106b8d:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106b90:	68 fd 03 00 00       	push   $0x3fd
80106b95:	e8 48 ff ff ff       	call   80106ae2 <inb>
80106b9a:	83 c4 04             	add    $0x4,%esp
80106b9d:	3c ff                	cmp    $0xff,%al
80106b9f:	74 6e                	je     80106c0f <uartinit+0xf1>
    return;
  uart = 1;
80106ba1:	c7 05 98 40 11 80 01 	movl   $0x1,0x80114098
80106ba8:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106bab:	68 fa 03 00 00       	push   $0x3fa
80106bb0:	e8 2d ff ff ff       	call   80106ae2 <inb>
80106bb5:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106bb8:	68 f8 03 00 00       	push   $0x3f8
80106bbd:	e8 20 ff ff ff       	call   80106ae2 <inb>
80106bc2:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80106bc5:	83 ec 0c             	sub    $0xc,%esp
80106bc8:	6a 04                	push   $0x4
80106bca:	e8 9c d3 ff ff       	call   80103f6b <picenable>
80106bcf:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80106bd2:	83 ec 08             	sub    $0x8,%esp
80106bd5:	6a 00                	push   $0x0
80106bd7:	6a 04                	push   $0x4
80106bd9:	e8 0e bf ff ff       	call   80102aec <ioapicenable>
80106bde:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106be1:	c7 45 f4 98 8b 10 80 	movl   $0x80108b98,-0xc(%ebp)
80106be8:	eb 19                	jmp    80106c03 <uartinit+0xe5>
    uartputc(*p);
80106bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bed:	0f b6 00             	movzbl (%eax),%eax
80106bf0:	0f be c0             	movsbl %al,%eax
80106bf3:	83 ec 0c             	sub    $0xc,%esp
80106bf6:	50                   	push   %eax
80106bf7:	e8 16 00 00 00       	call   80106c12 <uartputc>
80106bfc:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106bff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c06:	0f b6 00             	movzbl (%eax),%eax
80106c09:	84 c0                	test   %al,%al
80106c0b:	75 dd                	jne    80106bea <uartinit+0xcc>
80106c0d:	eb 01                	jmp    80106c10 <uartinit+0xf2>
    return;
80106c0f:	90                   	nop
}
80106c10:	c9                   	leave
80106c11:	c3                   	ret

80106c12 <uartputc>:

void
uartputc(int c)
{
80106c12:	55                   	push   %ebp
80106c13:	89 e5                	mov    %esp,%ebp
80106c15:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106c18:	a1 98 40 11 80       	mov    0x80114098,%eax
80106c1d:	85 c0                	test   %eax,%eax
80106c1f:	74 53                	je     80106c74 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106c28:	eb 11                	jmp    80106c3b <uartputc+0x29>
    microdelay(10);
80106c2a:	83 ec 0c             	sub    $0xc,%esp
80106c2d:	6a 0a                	push   $0xa
80106c2f:	e8 1d c4 ff ff       	call   80103051 <microdelay>
80106c34:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c37:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c3b:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106c3f:	7f 1a                	jg     80106c5b <uartputc+0x49>
80106c41:	83 ec 0c             	sub    $0xc,%esp
80106c44:	68 fd 03 00 00       	push   $0x3fd
80106c49:	e8 94 fe ff ff       	call   80106ae2 <inb>
80106c4e:	83 c4 10             	add    $0x10,%esp
80106c51:	0f b6 c0             	movzbl %al,%eax
80106c54:	83 e0 20             	and    $0x20,%eax
80106c57:	85 c0                	test   %eax,%eax
80106c59:	74 cf                	je     80106c2a <uartputc+0x18>
  outb(COM1+0, c);
80106c5b:	8b 45 08             	mov    0x8(%ebp),%eax
80106c5e:	0f b6 c0             	movzbl %al,%eax
80106c61:	83 ec 08             	sub    $0x8,%esp
80106c64:	50                   	push   %eax
80106c65:	68 f8 03 00 00       	push   $0x3f8
80106c6a:	e8 90 fe ff ff       	call   80106aff <outb>
80106c6f:	83 c4 10             	add    $0x10,%esp
80106c72:	eb 01                	jmp    80106c75 <uartputc+0x63>
    return;
80106c74:	90                   	nop
}
80106c75:	c9                   	leave
80106c76:	c3                   	ret

80106c77 <uartgetc>:

static int
uartgetc(void)
{
80106c77:	55                   	push   %ebp
80106c78:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106c7a:	a1 98 40 11 80       	mov    0x80114098,%eax
80106c7f:	85 c0                	test   %eax,%eax
80106c81:	75 07                	jne    80106c8a <uartgetc+0x13>
    return -1;
80106c83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c88:	eb 2e                	jmp    80106cb8 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106c8a:	68 fd 03 00 00       	push   $0x3fd
80106c8f:	e8 4e fe ff ff       	call   80106ae2 <inb>
80106c94:	83 c4 04             	add    $0x4,%esp
80106c97:	0f b6 c0             	movzbl %al,%eax
80106c9a:	83 e0 01             	and    $0x1,%eax
80106c9d:	85 c0                	test   %eax,%eax
80106c9f:	75 07                	jne    80106ca8 <uartgetc+0x31>
    return -1;
80106ca1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ca6:	eb 10                	jmp    80106cb8 <uartgetc+0x41>
  return inb(COM1+0);
80106ca8:	68 f8 03 00 00       	push   $0x3f8
80106cad:	e8 30 fe ff ff       	call   80106ae2 <inb>
80106cb2:	83 c4 04             	add    $0x4,%esp
80106cb5:	0f b6 c0             	movzbl %al,%eax
}
80106cb8:	c9                   	leave
80106cb9:	c3                   	ret

80106cba <uartintr>:

void
uartintr(void)
{
80106cba:	55                   	push   %ebp
80106cbb:	89 e5                	mov    %esp,%ebp
80106cbd:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106cc0:	83 ec 0c             	sub    $0xc,%esp
80106cc3:	68 77 6c 10 80       	push   $0x80106c77
80106cc8:	e8 49 9b ff ff       	call   80100816 <consoleintr>
80106ccd:	83 c4 10             	add    $0x10,%esp
}
80106cd0:	90                   	nop
80106cd1:	c9                   	leave
80106cd2:	c3                   	ret

80106cd3 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106cd3:	6a 00                	push   $0x0
  pushl $0
80106cd5:	6a 00                	push   $0x0
  jmp alltraps
80106cd7:	e9 a5 f9 ff ff       	jmp    80106681 <alltraps>

80106cdc <vector1>:
.globl vector1
vector1:
  pushl $0
80106cdc:	6a 00                	push   $0x0
  pushl $1
80106cde:	6a 01                	push   $0x1
  jmp alltraps
80106ce0:	e9 9c f9 ff ff       	jmp    80106681 <alltraps>

80106ce5 <vector2>:
.globl vector2
vector2:
  pushl $0
80106ce5:	6a 00                	push   $0x0
  pushl $2
80106ce7:	6a 02                	push   $0x2
  jmp alltraps
80106ce9:	e9 93 f9 ff ff       	jmp    80106681 <alltraps>

80106cee <vector3>:
.globl vector3
vector3:
  pushl $0
80106cee:	6a 00                	push   $0x0
  pushl $3
80106cf0:	6a 03                	push   $0x3
  jmp alltraps
80106cf2:	e9 8a f9 ff ff       	jmp    80106681 <alltraps>

80106cf7 <vector4>:
.globl vector4
vector4:
  pushl $0
80106cf7:	6a 00                	push   $0x0
  pushl $4
80106cf9:	6a 04                	push   $0x4
  jmp alltraps
80106cfb:	e9 81 f9 ff ff       	jmp    80106681 <alltraps>

80106d00 <vector5>:
.globl vector5
vector5:
  pushl $0
80106d00:	6a 00                	push   $0x0
  pushl $5
80106d02:	6a 05                	push   $0x5
  jmp alltraps
80106d04:	e9 78 f9 ff ff       	jmp    80106681 <alltraps>

80106d09 <vector6>:
.globl vector6
vector6:
  pushl $0
80106d09:	6a 00                	push   $0x0
  pushl $6
80106d0b:	6a 06                	push   $0x6
  jmp alltraps
80106d0d:	e9 6f f9 ff ff       	jmp    80106681 <alltraps>

80106d12 <vector7>:
.globl vector7
vector7:
  pushl $0
80106d12:	6a 00                	push   $0x0
  pushl $7
80106d14:	6a 07                	push   $0x7
  jmp alltraps
80106d16:	e9 66 f9 ff ff       	jmp    80106681 <alltraps>

80106d1b <vector8>:
.globl vector8
vector8:
  pushl $8
80106d1b:	6a 08                	push   $0x8
  jmp alltraps
80106d1d:	e9 5f f9 ff ff       	jmp    80106681 <alltraps>

80106d22 <vector9>:
.globl vector9
vector9:
  pushl $0
80106d22:	6a 00                	push   $0x0
  pushl $9
80106d24:	6a 09                	push   $0x9
  jmp alltraps
80106d26:	e9 56 f9 ff ff       	jmp    80106681 <alltraps>

80106d2b <vector10>:
.globl vector10
vector10:
  pushl $10
80106d2b:	6a 0a                	push   $0xa
  jmp alltraps
80106d2d:	e9 4f f9 ff ff       	jmp    80106681 <alltraps>

80106d32 <vector11>:
.globl vector11
vector11:
  pushl $11
80106d32:	6a 0b                	push   $0xb
  jmp alltraps
80106d34:	e9 48 f9 ff ff       	jmp    80106681 <alltraps>

80106d39 <vector12>:
.globl vector12
vector12:
  pushl $12
80106d39:	6a 0c                	push   $0xc
  jmp alltraps
80106d3b:	e9 41 f9 ff ff       	jmp    80106681 <alltraps>

80106d40 <vector13>:
.globl vector13
vector13:
  pushl $13
80106d40:	6a 0d                	push   $0xd
  jmp alltraps
80106d42:	e9 3a f9 ff ff       	jmp    80106681 <alltraps>

80106d47 <vector14>:
.globl vector14
vector14:
  pushl $14
80106d47:	6a 0e                	push   $0xe
  jmp alltraps
80106d49:	e9 33 f9 ff ff       	jmp    80106681 <alltraps>

80106d4e <vector15>:
.globl vector15
vector15:
  pushl $0
80106d4e:	6a 00                	push   $0x0
  pushl $15
80106d50:	6a 0f                	push   $0xf
  jmp alltraps
80106d52:	e9 2a f9 ff ff       	jmp    80106681 <alltraps>

80106d57 <vector16>:
.globl vector16
vector16:
  pushl $0
80106d57:	6a 00                	push   $0x0
  pushl $16
80106d59:	6a 10                	push   $0x10
  jmp alltraps
80106d5b:	e9 21 f9 ff ff       	jmp    80106681 <alltraps>

80106d60 <vector17>:
.globl vector17
vector17:
  pushl $17
80106d60:	6a 11                	push   $0x11
  jmp alltraps
80106d62:	e9 1a f9 ff ff       	jmp    80106681 <alltraps>

80106d67 <vector18>:
.globl vector18
vector18:
  pushl $0
80106d67:	6a 00                	push   $0x0
  pushl $18
80106d69:	6a 12                	push   $0x12
  jmp alltraps
80106d6b:	e9 11 f9 ff ff       	jmp    80106681 <alltraps>

80106d70 <vector19>:
.globl vector19
vector19:
  pushl $0
80106d70:	6a 00                	push   $0x0
  pushl $19
80106d72:	6a 13                	push   $0x13
  jmp alltraps
80106d74:	e9 08 f9 ff ff       	jmp    80106681 <alltraps>

80106d79 <vector20>:
.globl vector20
vector20:
  pushl $0
80106d79:	6a 00                	push   $0x0
  pushl $20
80106d7b:	6a 14                	push   $0x14
  jmp alltraps
80106d7d:	e9 ff f8 ff ff       	jmp    80106681 <alltraps>

80106d82 <vector21>:
.globl vector21
vector21:
  pushl $0
80106d82:	6a 00                	push   $0x0
  pushl $21
80106d84:	6a 15                	push   $0x15
  jmp alltraps
80106d86:	e9 f6 f8 ff ff       	jmp    80106681 <alltraps>

80106d8b <vector22>:
.globl vector22
vector22:
  pushl $0
80106d8b:	6a 00                	push   $0x0
  pushl $22
80106d8d:	6a 16                	push   $0x16
  jmp alltraps
80106d8f:	e9 ed f8 ff ff       	jmp    80106681 <alltraps>

80106d94 <vector23>:
.globl vector23
vector23:
  pushl $0
80106d94:	6a 00                	push   $0x0
  pushl $23
80106d96:	6a 17                	push   $0x17
  jmp alltraps
80106d98:	e9 e4 f8 ff ff       	jmp    80106681 <alltraps>

80106d9d <vector24>:
.globl vector24
vector24:
  pushl $0
80106d9d:	6a 00                	push   $0x0
  pushl $24
80106d9f:	6a 18                	push   $0x18
  jmp alltraps
80106da1:	e9 db f8 ff ff       	jmp    80106681 <alltraps>

80106da6 <vector25>:
.globl vector25
vector25:
  pushl $0
80106da6:	6a 00                	push   $0x0
  pushl $25
80106da8:	6a 19                	push   $0x19
  jmp alltraps
80106daa:	e9 d2 f8 ff ff       	jmp    80106681 <alltraps>

80106daf <vector26>:
.globl vector26
vector26:
  pushl $0
80106daf:	6a 00                	push   $0x0
  pushl $26
80106db1:	6a 1a                	push   $0x1a
  jmp alltraps
80106db3:	e9 c9 f8 ff ff       	jmp    80106681 <alltraps>

80106db8 <vector27>:
.globl vector27
vector27:
  pushl $0
80106db8:	6a 00                	push   $0x0
  pushl $27
80106dba:	6a 1b                	push   $0x1b
  jmp alltraps
80106dbc:	e9 c0 f8 ff ff       	jmp    80106681 <alltraps>

80106dc1 <vector28>:
.globl vector28
vector28:
  pushl $0
80106dc1:	6a 00                	push   $0x0
  pushl $28
80106dc3:	6a 1c                	push   $0x1c
  jmp alltraps
80106dc5:	e9 b7 f8 ff ff       	jmp    80106681 <alltraps>

80106dca <vector29>:
.globl vector29
vector29:
  pushl $0
80106dca:	6a 00                	push   $0x0
  pushl $29
80106dcc:	6a 1d                	push   $0x1d
  jmp alltraps
80106dce:	e9 ae f8 ff ff       	jmp    80106681 <alltraps>

80106dd3 <vector30>:
.globl vector30
vector30:
  pushl $0
80106dd3:	6a 00                	push   $0x0
  pushl $30
80106dd5:	6a 1e                	push   $0x1e
  jmp alltraps
80106dd7:	e9 a5 f8 ff ff       	jmp    80106681 <alltraps>

80106ddc <vector31>:
.globl vector31
vector31:
  pushl $0
80106ddc:	6a 00                	push   $0x0
  pushl $31
80106dde:	6a 1f                	push   $0x1f
  jmp alltraps
80106de0:	e9 9c f8 ff ff       	jmp    80106681 <alltraps>

80106de5 <vector32>:
.globl vector32
vector32:
  pushl $0
80106de5:	6a 00                	push   $0x0
  pushl $32
80106de7:	6a 20                	push   $0x20
  jmp alltraps
80106de9:	e9 93 f8 ff ff       	jmp    80106681 <alltraps>

80106dee <vector33>:
.globl vector33
vector33:
  pushl $0
80106dee:	6a 00                	push   $0x0
  pushl $33
80106df0:	6a 21                	push   $0x21
  jmp alltraps
80106df2:	e9 8a f8 ff ff       	jmp    80106681 <alltraps>

80106df7 <vector34>:
.globl vector34
vector34:
  pushl $0
80106df7:	6a 00                	push   $0x0
  pushl $34
80106df9:	6a 22                	push   $0x22
  jmp alltraps
80106dfb:	e9 81 f8 ff ff       	jmp    80106681 <alltraps>

80106e00 <vector35>:
.globl vector35
vector35:
  pushl $0
80106e00:	6a 00                	push   $0x0
  pushl $35
80106e02:	6a 23                	push   $0x23
  jmp alltraps
80106e04:	e9 78 f8 ff ff       	jmp    80106681 <alltraps>

80106e09 <vector36>:
.globl vector36
vector36:
  pushl $0
80106e09:	6a 00                	push   $0x0
  pushl $36
80106e0b:	6a 24                	push   $0x24
  jmp alltraps
80106e0d:	e9 6f f8 ff ff       	jmp    80106681 <alltraps>

80106e12 <vector37>:
.globl vector37
vector37:
  pushl $0
80106e12:	6a 00                	push   $0x0
  pushl $37
80106e14:	6a 25                	push   $0x25
  jmp alltraps
80106e16:	e9 66 f8 ff ff       	jmp    80106681 <alltraps>

80106e1b <vector38>:
.globl vector38
vector38:
  pushl $0
80106e1b:	6a 00                	push   $0x0
  pushl $38
80106e1d:	6a 26                	push   $0x26
  jmp alltraps
80106e1f:	e9 5d f8 ff ff       	jmp    80106681 <alltraps>

80106e24 <vector39>:
.globl vector39
vector39:
  pushl $0
80106e24:	6a 00                	push   $0x0
  pushl $39
80106e26:	6a 27                	push   $0x27
  jmp alltraps
80106e28:	e9 54 f8 ff ff       	jmp    80106681 <alltraps>

80106e2d <vector40>:
.globl vector40
vector40:
  pushl $0
80106e2d:	6a 00                	push   $0x0
  pushl $40
80106e2f:	6a 28                	push   $0x28
  jmp alltraps
80106e31:	e9 4b f8 ff ff       	jmp    80106681 <alltraps>

80106e36 <vector41>:
.globl vector41
vector41:
  pushl $0
80106e36:	6a 00                	push   $0x0
  pushl $41
80106e38:	6a 29                	push   $0x29
  jmp alltraps
80106e3a:	e9 42 f8 ff ff       	jmp    80106681 <alltraps>

80106e3f <vector42>:
.globl vector42
vector42:
  pushl $0
80106e3f:	6a 00                	push   $0x0
  pushl $42
80106e41:	6a 2a                	push   $0x2a
  jmp alltraps
80106e43:	e9 39 f8 ff ff       	jmp    80106681 <alltraps>

80106e48 <vector43>:
.globl vector43
vector43:
  pushl $0
80106e48:	6a 00                	push   $0x0
  pushl $43
80106e4a:	6a 2b                	push   $0x2b
  jmp alltraps
80106e4c:	e9 30 f8 ff ff       	jmp    80106681 <alltraps>

80106e51 <vector44>:
.globl vector44
vector44:
  pushl $0
80106e51:	6a 00                	push   $0x0
  pushl $44
80106e53:	6a 2c                	push   $0x2c
  jmp alltraps
80106e55:	e9 27 f8 ff ff       	jmp    80106681 <alltraps>

80106e5a <vector45>:
.globl vector45
vector45:
  pushl $0
80106e5a:	6a 00                	push   $0x0
  pushl $45
80106e5c:	6a 2d                	push   $0x2d
  jmp alltraps
80106e5e:	e9 1e f8 ff ff       	jmp    80106681 <alltraps>

80106e63 <vector46>:
.globl vector46
vector46:
  pushl $0
80106e63:	6a 00                	push   $0x0
  pushl $46
80106e65:	6a 2e                	push   $0x2e
  jmp alltraps
80106e67:	e9 15 f8 ff ff       	jmp    80106681 <alltraps>

80106e6c <vector47>:
.globl vector47
vector47:
  pushl $0
80106e6c:	6a 00                	push   $0x0
  pushl $47
80106e6e:	6a 2f                	push   $0x2f
  jmp alltraps
80106e70:	e9 0c f8 ff ff       	jmp    80106681 <alltraps>

80106e75 <vector48>:
.globl vector48
vector48:
  pushl $0
80106e75:	6a 00                	push   $0x0
  pushl $48
80106e77:	6a 30                	push   $0x30
  jmp alltraps
80106e79:	e9 03 f8 ff ff       	jmp    80106681 <alltraps>

80106e7e <vector49>:
.globl vector49
vector49:
  pushl $0
80106e7e:	6a 00                	push   $0x0
  pushl $49
80106e80:	6a 31                	push   $0x31
  jmp alltraps
80106e82:	e9 fa f7 ff ff       	jmp    80106681 <alltraps>

80106e87 <vector50>:
.globl vector50
vector50:
  pushl $0
80106e87:	6a 00                	push   $0x0
  pushl $50
80106e89:	6a 32                	push   $0x32
  jmp alltraps
80106e8b:	e9 f1 f7 ff ff       	jmp    80106681 <alltraps>

80106e90 <vector51>:
.globl vector51
vector51:
  pushl $0
80106e90:	6a 00                	push   $0x0
  pushl $51
80106e92:	6a 33                	push   $0x33
  jmp alltraps
80106e94:	e9 e8 f7 ff ff       	jmp    80106681 <alltraps>

80106e99 <vector52>:
.globl vector52
vector52:
  pushl $0
80106e99:	6a 00                	push   $0x0
  pushl $52
80106e9b:	6a 34                	push   $0x34
  jmp alltraps
80106e9d:	e9 df f7 ff ff       	jmp    80106681 <alltraps>

80106ea2 <vector53>:
.globl vector53
vector53:
  pushl $0
80106ea2:	6a 00                	push   $0x0
  pushl $53
80106ea4:	6a 35                	push   $0x35
  jmp alltraps
80106ea6:	e9 d6 f7 ff ff       	jmp    80106681 <alltraps>

80106eab <vector54>:
.globl vector54
vector54:
  pushl $0
80106eab:	6a 00                	push   $0x0
  pushl $54
80106ead:	6a 36                	push   $0x36
  jmp alltraps
80106eaf:	e9 cd f7 ff ff       	jmp    80106681 <alltraps>

80106eb4 <vector55>:
.globl vector55
vector55:
  pushl $0
80106eb4:	6a 00                	push   $0x0
  pushl $55
80106eb6:	6a 37                	push   $0x37
  jmp alltraps
80106eb8:	e9 c4 f7 ff ff       	jmp    80106681 <alltraps>

80106ebd <vector56>:
.globl vector56
vector56:
  pushl $0
80106ebd:	6a 00                	push   $0x0
  pushl $56
80106ebf:	6a 38                	push   $0x38
  jmp alltraps
80106ec1:	e9 bb f7 ff ff       	jmp    80106681 <alltraps>

80106ec6 <vector57>:
.globl vector57
vector57:
  pushl $0
80106ec6:	6a 00                	push   $0x0
  pushl $57
80106ec8:	6a 39                	push   $0x39
  jmp alltraps
80106eca:	e9 b2 f7 ff ff       	jmp    80106681 <alltraps>

80106ecf <vector58>:
.globl vector58
vector58:
  pushl $0
80106ecf:	6a 00                	push   $0x0
  pushl $58
80106ed1:	6a 3a                	push   $0x3a
  jmp alltraps
80106ed3:	e9 a9 f7 ff ff       	jmp    80106681 <alltraps>

80106ed8 <vector59>:
.globl vector59
vector59:
  pushl $0
80106ed8:	6a 00                	push   $0x0
  pushl $59
80106eda:	6a 3b                	push   $0x3b
  jmp alltraps
80106edc:	e9 a0 f7 ff ff       	jmp    80106681 <alltraps>

80106ee1 <vector60>:
.globl vector60
vector60:
  pushl $0
80106ee1:	6a 00                	push   $0x0
  pushl $60
80106ee3:	6a 3c                	push   $0x3c
  jmp alltraps
80106ee5:	e9 97 f7 ff ff       	jmp    80106681 <alltraps>

80106eea <vector61>:
.globl vector61
vector61:
  pushl $0
80106eea:	6a 00                	push   $0x0
  pushl $61
80106eec:	6a 3d                	push   $0x3d
  jmp alltraps
80106eee:	e9 8e f7 ff ff       	jmp    80106681 <alltraps>

80106ef3 <vector62>:
.globl vector62
vector62:
  pushl $0
80106ef3:	6a 00                	push   $0x0
  pushl $62
80106ef5:	6a 3e                	push   $0x3e
  jmp alltraps
80106ef7:	e9 85 f7 ff ff       	jmp    80106681 <alltraps>

80106efc <vector63>:
.globl vector63
vector63:
  pushl $0
80106efc:	6a 00                	push   $0x0
  pushl $63
80106efe:	6a 3f                	push   $0x3f
  jmp alltraps
80106f00:	e9 7c f7 ff ff       	jmp    80106681 <alltraps>

80106f05 <vector64>:
.globl vector64
vector64:
  pushl $0
80106f05:	6a 00                	push   $0x0
  pushl $64
80106f07:	6a 40                	push   $0x40
  jmp alltraps
80106f09:	e9 73 f7 ff ff       	jmp    80106681 <alltraps>

80106f0e <vector65>:
.globl vector65
vector65:
  pushl $0
80106f0e:	6a 00                	push   $0x0
  pushl $65
80106f10:	6a 41                	push   $0x41
  jmp alltraps
80106f12:	e9 6a f7 ff ff       	jmp    80106681 <alltraps>

80106f17 <vector66>:
.globl vector66
vector66:
  pushl $0
80106f17:	6a 00                	push   $0x0
  pushl $66
80106f19:	6a 42                	push   $0x42
  jmp alltraps
80106f1b:	e9 61 f7 ff ff       	jmp    80106681 <alltraps>

80106f20 <vector67>:
.globl vector67
vector67:
  pushl $0
80106f20:	6a 00                	push   $0x0
  pushl $67
80106f22:	6a 43                	push   $0x43
  jmp alltraps
80106f24:	e9 58 f7 ff ff       	jmp    80106681 <alltraps>

80106f29 <vector68>:
.globl vector68
vector68:
  pushl $0
80106f29:	6a 00                	push   $0x0
  pushl $68
80106f2b:	6a 44                	push   $0x44
  jmp alltraps
80106f2d:	e9 4f f7 ff ff       	jmp    80106681 <alltraps>

80106f32 <vector69>:
.globl vector69
vector69:
  pushl $0
80106f32:	6a 00                	push   $0x0
  pushl $69
80106f34:	6a 45                	push   $0x45
  jmp alltraps
80106f36:	e9 46 f7 ff ff       	jmp    80106681 <alltraps>

80106f3b <vector70>:
.globl vector70
vector70:
  pushl $0
80106f3b:	6a 00                	push   $0x0
  pushl $70
80106f3d:	6a 46                	push   $0x46
  jmp alltraps
80106f3f:	e9 3d f7 ff ff       	jmp    80106681 <alltraps>

80106f44 <vector71>:
.globl vector71
vector71:
  pushl $0
80106f44:	6a 00                	push   $0x0
  pushl $71
80106f46:	6a 47                	push   $0x47
  jmp alltraps
80106f48:	e9 34 f7 ff ff       	jmp    80106681 <alltraps>

80106f4d <vector72>:
.globl vector72
vector72:
  pushl $0
80106f4d:	6a 00                	push   $0x0
  pushl $72
80106f4f:	6a 48                	push   $0x48
  jmp alltraps
80106f51:	e9 2b f7 ff ff       	jmp    80106681 <alltraps>

80106f56 <vector73>:
.globl vector73
vector73:
  pushl $0
80106f56:	6a 00                	push   $0x0
  pushl $73
80106f58:	6a 49                	push   $0x49
  jmp alltraps
80106f5a:	e9 22 f7 ff ff       	jmp    80106681 <alltraps>

80106f5f <vector74>:
.globl vector74
vector74:
  pushl $0
80106f5f:	6a 00                	push   $0x0
  pushl $74
80106f61:	6a 4a                	push   $0x4a
  jmp alltraps
80106f63:	e9 19 f7 ff ff       	jmp    80106681 <alltraps>

80106f68 <vector75>:
.globl vector75
vector75:
  pushl $0
80106f68:	6a 00                	push   $0x0
  pushl $75
80106f6a:	6a 4b                	push   $0x4b
  jmp alltraps
80106f6c:	e9 10 f7 ff ff       	jmp    80106681 <alltraps>

80106f71 <vector76>:
.globl vector76
vector76:
  pushl $0
80106f71:	6a 00                	push   $0x0
  pushl $76
80106f73:	6a 4c                	push   $0x4c
  jmp alltraps
80106f75:	e9 07 f7 ff ff       	jmp    80106681 <alltraps>

80106f7a <vector77>:
.globl vector77
vector77:
  pushl $0
80106f7a:	6a 00                	push   $0x0
  pushl $77
80106f7c:	6a 4d                	push   $0x4d
  jmp alltraps
80106f7e:	e9 fe f6 ff ff       	jmp    80106681 <alltraps>

80106f83 <vector78>:
.globl vector78
vector78:
  pushl $0
80106f83:	6a 00                	push   $0x0
  pushl $78
80106f85:	6a 4e                	push   $0x4e
  jmp alltraps
80106f87:	e9 f5 f6 ff ff       	jmp    80106681 <alltraps>

80106f8c <vector79>:
.globl vector79
vector79:
  pushl $0
80106f8c:	6a 00                	push   $0x0
  pushl $79
80106f8e:	6a 4f                	push   $0x4f
  jmp alltraps
80106f90:	e9 ec f6 ff ff       	jmp    80106681 <alltraps>

80106f95 <vector80>:
.globl vector80
vector80:
  pushl $0
80106f95:	6a 00                	push   $0x0
  pushl $80
80106f97:	6a 50                	push   $0x50
  jmp alltraps
80106f99:	e9 e3 f6 ff ff       	jmp    80106681 <alltraps>

80106f9e <vector81>:
.globl vector81
vector81:
  pushl $0
80106f9e:	6a 00                	push   $0x0
  pushl $81
80106fa0:	6a 51                	push   $0x51
  jmp alltraps
80106fa2:	e9 da f6 ff ff       	jmp    80106681 <alltraps>

80106fa7 <vector82>:
.globl vector82
vector82:
  pushl $0
80106fa7:	6a 00                	push   $0x0
  pushl $82
80106fa9:	6a 52                	push   $0x52
  jmp alltraps
80106fab:	e9 d1 f6 ff ff       	jmp    80106681 <alltraps>

80106fb0 <vector83>:
.globl vector83
vector83:
  pushl $0
80106fb0:	6a 00                	push   $0x0
  pushl $83
80106fb2:	6a 53                	push   $0x53
  jmp alltraps
80106fb4:	e9 c8 f6 ff ff       	jmp    80106681 <alltraps>

80106fb9 <vector84>:
.globl vector84
vector84:
  pushl $0
80106fb9:	6a 00                	push   $0x0
  pushl $84
80106fbb:	6a 54                	push   $0x54
  jmp alltraps
80106fbd:	e9 bf f6 ff ff       	jmp    80106681 <alltraps>

80106fc2 <vector85>:
.globl vector85
vector85:
  pushl $0
80106fc2:	6a 00                	push   $0x0
  pushl $85
80106fc4:	6a 55                	push   $0x55
  jmp alltraps
80106fc6:	e9 b6 f6 ff ff       	jmp    80106681 <alltraps>

80106fcb <vector86>:
.globl vector86
vector86:
  pushl $0
80106fcb:	6a 00                	push   $0x0
  pushl $86
80106fcd:	6a 56                	push   $0x56
  jmp alltraps
80106fcf:	e9 ad f6 ff ff       	jmp    80106681 <alltraps>

80106fd4 <vector87>:
.globl vector87
vector87:
  pushl $0
80106fd4:	6a 00                	push   $0x0
  pushl $87
80106fd6:	6a 57                	push   $0x57
  jmp alltraps
80106fd8:	e9 a4 f6 ff ff       	jmp    80106681 <alltraps>

80106fdd <vector88>:
.globl vector88
vector88:
  pushl $0
80106fdd:	6a 00                	push   $0x0
  pushl $88
80106fdf:	6a 58                	push   $0x58
  jmp alltraps
80106fe1:	e9 9b f6 ff ff       	jmp    80106681 <alltraps>

80106fe6 <vector89>:
.globl vector89
vector89:
  pushl $0
80106fe6:	6a 00                	push   $0x0
  pushl $89
80106fe8:	6a 59                	push   $0x59
  jmp alltraps
80106fea:	e9 92 f6 ff ff       	jmp    80106681 <alltraps>

80106fef <vector90>:
.globl vector90
vector90:
  pushl $0
80106fef:	6a 00                	push   $0x0
  pushl $90
80106ff1:	6a 5a                	push   $0x5a
  jmp alltraps
80106ff3:	e9 89 f6 ff ff       	jmp    80106681 <alltraps>

80106ff8 <vector91>:
.globl vector91
vector91:
  pushl $0
80106ff8:	6a 00                	push   $0x0
  pushl $91
80106ffa:	6a 5b                	push   $0x5b
  jmp alltraps
80106ffc:	e9 80 f6 ff ff       	jmp    80106681 <alltraps>

80107001 <vector92>:
.globl vector92
vector92:
  pushl $0
80107001:	6a 00                	push   $0x0
  pushl $92
80107003:	6a 5c                	push   $0x5c
  jmp alltraps
80107005:	e9 77 f6 ff ff       	jmp    80106681 <alltraps>

8010700a <vector93>:
.globl vector93
vector93:
  pushl $0
8010700a:	6a 00                	push   $0x0
  pushl $93
8010700c:	6a 5d                	push   $0x5d
  jmp alltraps
8010700e:	e9 6e f6 ff ff       	jmp    80106681 <alltraps>

80107013 <vector94>:
.globl vector94
vector94:
  pushl $0
80107013:	6a 00                	push   $0x0
  pushl $94
80107015:	6a 5e                	push   $0x5e
  jmp alltraps
80107017:	e9 65 f6 ff ff       	jmp    80106681 <alltraps>

8010701c <vector95>:
.globl vector95
vector95:
  pushl $0
8010701c:	6a 00                	push   $0x0
  pushl $95
8010701e:	6a 5f                	push   $0x5f
  jmp alltraps
80107020:	e9 5c f6 ff ff       	jmp    80106681 <alltraps>

80107025 <vector96>:
.globl vector96
vector96:
  pushl $0
80107025:	6a 00                	push   $0x0
  pushl $96
80107027:	6a 60                	push   $0x60
  jmp alltraps
80107029:	e9 53 f6 ff ff       	jmp    80106681 <alltraps>

8010702e <vector97>:
.globl vector97
vector97:
  pushl $0
8010702e:	6a 00                	push   $0x0
  pushl $97
80107030:	6a 61                	push   $0x61
  jmp alltraps
80107032:	e9 4a f6 ff ff       	jmp    80106681 <alltraps>

80107037 <vector98>:
.globl vector98
vector98:
  pushl $0
80107037:	6a 00                	push   $0x0
  pushl $98
80107039:	6a 62                	push   $0x62
  jmp alltraps
8010703b:	e9 41 f6 ff ff       	jmp    80106681 <alltraps>

80107040 <vector99>:
.globl vector99
vector99:
  pushl $0
80107040:	6a 00                	push   $0x0
  pushl $99
80107042:	6a 63                	push   $0x63
  jmp alltraps
80107044:	e9 38 f6 ff ff       	jmp    80106681 <alltraps>

80107049 <vector100>:
.globl vector100
vector100:
  pushl $0
80107049:	6a 00                	push   $0x0
  pushl $100
8010704b:	6a 64                	push   $0x64
  jmp alltraps
8010704d:	e9 2f f6 ff ff       	jmp    80106681 <alltraps>

80107052 <vector101>:
.globl vector101
vector101:
  pushl $0
80107052:	6a 00                	push   $0x0
  pushl $101
80107054:	6a 65                	push   $0x65
  jmp alltraps
80107056:	e9 26 f6 ff ff       	jmp    80106681 <alltraps>

8010705b <vector102>:
.globl vector102
vector102:
  pushl $0
8010705b:	6a 00                	push   $0x0
  pushl $102
8010705d:	6a 66                	push   $0x66
  jmp alltraps
8010705f:	e9 1d f6 ff ff       	jmp    80106681 <alltraps>

80107064 <vector103>:
.globl vector103
vector103:
  pushl $0
80107064:	6a 00                	push   $0x0
  pushl $103
80107066:	6a 67                	push   $0x67
  jmp alltraps
80107068:	e9 14 f6 ff ff       	jmp    80106681 <alltraps>

8010706d <vector104>:
.globl vector104
vector104:
  pushl $0
8010706d:	6a 00                	push   $0x0
  pushl $104
8010706f:	6a 68                	push   $0x68
  jmp alltraps
80107071:	e9 0b f6 ff ff       	jmp    80106681 <alltraps>

80107076 <vector105>:
.globl vector105
vector105:
  pushl $0
80107076:	6a 00                	push   $0x0
  pushl $105
80107078:	6a 69                	push   $0x69
  jmp alltraps
8010707a:	e9 02 f6 ff ff       	jmp    80106681 <alltraps>

8010707f <vector106>:
.globl vector106
vector106:
  pushl $0
8010707f:	6a 00                	push   $0x0
  pushl $106
80107081:	6a 6a                	push   $0x6a
  jmp alltraps
80107083:	e9 f9 f5 ff ff       	jmp    80106681 <alltraps>

80107088 <vector107>:
.globl vector107
vector107:
  pushl $0
80107088:	6a 00                	push   $0x0
  pushl $107
8010708a:	6a 6b                	push   $0x6b
  jmp alltraps
8010708c:	e9 f0 f5 ff ff       	jmp    80106681 <alltraps>

80107091 <vector108>:
.globl vector108
vector108:
  pushl $0
80107091:	6a 00                	push   $0x0
  pushl $108
80107093:	6a 6c                	push   $0x6c
  jmp alltraps
80107095:	e9 e7 f5 ff ff       	jmp    80106681 <alltraps>

8010709a <vector109>:
.globl vector109
vector109:
  pushl $0
8010709a:	6a 00                	push   $0x0
  pushl $109
8010709c:	6a 6d                	push   $0x6d
  jmp alltraps
8010709e:	e9 de f5 ff ff       	jmp    80106681 <alltraps>

801070a3 <vector110>:
.globl vector110
vector110:
  pushl $0
801070a3:	6a 00                	push   $0x0
  pushl $110
801070a5:	6a 6e                	push   $0x6e
  jmp alltraps
801070a7:	e9 d5 f5 ff ff       	jmp    80106681 <alltraps>

801070ac <vector111>:
.globl vector111
vector111:
  pushl $0
801070ac:	6a 00                	push   $0x0
  pushl $111
801070ae:	6a 6f                	push   $0x6f
  jmp alltraps
801070b0:	e9 cc f5 ff ff       	jmp    80106681 <alltraps>

801070b5 <vector112>:
.globl vector112
vector112:
  pushl $0
801070b5:	6a 00                	push   $0x0
  pushl $112
801070b7:	6a 70                	push   $0x70
  jmp alltraps
801070b9:	e9 c3 f5 ff ff       	jmp    80106681 <alltraps>

801070be <vector113>:
.globl vector113
vector113:
  pushl $0
801070be:	6a 00                	push   $0x0
  pushl $113
801070c0:	6a 71                	push   $0x71
  jmp alltraps
801070c2:	e9 ba f5 ff ff       	jmp    80106681 <alltraps>

801070c7 <vector114>:
.globl vector114
vector114:
  pushl $0
801070c7:	6a 00                	push   $0x0
  pushl $114
801070c9:	6a 72                	push   $0x72
  jmp alltraps
801070cb:	e9 b1 f5 ff ff       	jmp    80106681 <alltraps>

801070d0 <vector115>:
.globl vector115
vector115:
  pushl $0
801070d0:	6a 00                	push   $0x0
  pushl $115
801070d2:	6a 73                	push   $0x73
  jmp alltraps
801070d4:	e9 a8 f5 ff ff       	jmp    80106681 <alltraps>

801070d9 <vector116>:
.globl vector116
vector116:
  pushl $0
801070d9:	6a 00                	push   $0x0
  pushl $116
801070db:	6a 74                	push   $0x74
  jmp alltraps
801070dd:	e9 9f f5 ff ff       	jmp    80106681 <alltraps>

801070e2 <vector117>:
.globl vector117
vector117:
  pushl $0
801070e2:	6a 00                	push   $0x0
  pushl $117
801070e4:	6a 75                	push   $0x75
  jmp alltraps
801070e6:	e9 96 f5 ff ff       	jmp    80106681 <alltraps>

801070eb <vector118>:
.globl vector118
vector118:
  pushl $0
801070eb:	6a 00                	push   $0x0
  pushl $118
801070ed:	6a 76                	push   $0x76
  jmp alltraps
801070ef:	e9 8d f5 ff ff       	jmp    80106681 <alltraps>

801070f4 <vector119>:
.globl vector119
vector119:
  pushl $0
801070f4:	6a 00                	push   $0x0
  pushl $119
801070f6:	6a 77                	push   $0x77
  jmp alltraps
801070f8:	e9 84 f5 ff ff       	jmp    80106681 <alltraps>

801070fd <vector120>:
.globl vector120
vector120:
  pushl $0
801070fd:	6a 00                	push   $0x0
  pushl $120
801070ff:	6a 78                	push   $0x78
  jmp alltraps
80107101:	e9 7b f5 ff ff       	jmp    80106681 <alltraps>

80107106 <vector121>:
.globl vector121
vector121:
  pushl $0
80107106:	6a 00                	push   $0x0
  pushl $121
80107108:	6a 79                	push   $0x79
  jmp alltraps
8010710a:	e9 72 f5 ff ff       	jmp    80106681 <alltraps>

8010710f <vector122>:
.globl vector122
vector122:
  pushl $0
8010710f:	6a 00                	push   $0x0
  pushl $122
80107111:	6a 7a                	push   $0x7a
  jmp alltraps
80107113:	e9 69 f5 ff ff       	jmp    80106681 <alltraps>

80107118 <vector123>:
.globl vector123
vector123:
  pushl $0
80107118:	6a 00                	push   $0x0
  pushl $123
8010711a:	6a 7b                	push   $0x7b
  jmp alltraps
8010711c:	e9 60 f5 ff ff       	jmp    80106681 <alltraps>

80107121 <vector124>:
.globl vector124
vector124:
  pushl $0
80107121:	6a 00                	push   $0x0
  pushl $124
80107123:	6a 7c                	push   $0x7c
  jmp alltraps
80107125:	e9 57 f5 ff ff       	jmp    80106681 <alltraps>

8010712a <vector125>:
.globl vector125
vector125:
  pushl $0
8010712a:	6a 00                	push   $0x0
  pushl $125
8010712c:	6a 7d                	push   $0x7d
  jmp alltraps
8010712e:	e9 4e f5 ff ff       	jmp    80106681 <alltraps>

80107133 <vector126>:
.globl vector126
vector126:
  pushl $0
80107133:	6a 00                	push   $0x0
  pushl $126
80107135:	6a 7e                	push   $0x7e
  jmp alltraps
80107137:	e9 45 f5 ff ff       	jmp    80106681 <alltraps>

8010713c <vector127>:
.globl vector127
vector127:
  pushl $0
8010713c:	6a 00                	push   $0x0
  pushl $127
8010713e:	6a 7f                	push   $0x7f
  jmp alltraps
80107140:	e9 3c f5 ff ff       	jmp    80106681 <alltraps>

80107145 <vector128>:
.globl vector128
vector128:
  pushl $0
80107145:	6a 00                	push   $0x0
  pushl $128
80107147:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010714c:	e9 30 f5 ff ff       	jmp    80106681 <alltraps>

80107151 <vector129>:
.globl vector129
vector129:
  pushl $0
80107151:	6a 00                	push   $0x0
  pushl $129
80107153:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107158:	e9 24 f5 ff ff       	jmp    80106681 <alltraps>

8010715d <vector130>:
.globl vector130
vector130:
  pushl $0
8010715d:	6a 00                	push   $0x0
  pushl $130
8010715f:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107164:	e9 18 f5 ff ff       	jmp    80106681 <alltraps>

80107169 <vector131>:
.globl vector131
vector131:
  pushl $0
80107169:	6a 00                	push   $0x0
  pushl $131
8010716b:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107170:	e9 0c f5 ff ff       	jmp    80106681 <alltraps>

80107175 <vector132>:
.globl vector132
vector132:
  pushl $0
80107175:	6a 00                	push   $0x0
  pushl $132
80107177:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010717c:	e9 00 f5 ff ff       	jmp    80106681 <alltraps>

80107181 <vector133>:
.globl vector133
vector133:
  pushl $0
80107181:	6a 00                	push   $0x0
  pushl $133
80107183:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107188:	e9 f4 f4 ff ff       	jmp    80106681 <alltraps>

8010718d <vector134>:
.globl vector134
vector134:
  pushl $0
8010718d:	6a 00                	push   $0x0
  pushl $134
8010718f:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107194:	e9 e8 f4 ff ff       	jmp    80106681 <alltraps>

80107199 <vector135>:
.globl vector135
vector135:
  pushl $0
80107199:	6a 00                	push   $0x0
  pushl $135
8010719b:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801071a0:	e9 dc f4 ff ff       	jmp    80106681 <alltraps>

801071a5 <vector136>:
.globl vector136
vector136:
  pushl $0
801071a5:	6a 00                	push   $0x0
  pushl $136
801071a7:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801071ac:	e9 d0 f4 ff ff       	jmp    80106681 <alltraps>

801071b1 <vector137>:
.globl vector137
vector137:
  pushl $0
801071b1:	6a 00                	push   $0x0
  pushl $137
801071b3:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801071b8:	e9 c4 f4 ff ff       	jmp    80106681 <alltraps>

801071bd <vector138>:
.globl vector138
vector138:
  pushl $0
801071bd:	6a 00                	push   $0x0
  pushl $138
801071bf:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801071c4:	e9 b8 f4 ff ff       	jmp    80106681 <alltraps>

801071c9 <vector139>:
.globl vector139
vector139:
  pushl $0
801071c9:	6a 00                	push   $0x0
  pushl $139
801071cb:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801071d0:	e9 ac f4 ff ff       	jmp    80106681 <alltraps>

801071d5 <vector140>:
.globl vector140
vector140:
  pushl $0
801071d5:	6a 00                	push   $0x0
  pushl $140
801071d7:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801071dc:	e9 a0 f4 ff ff       	jmp    80106681 <alltraps>

801071e1 <vector141>:
.globl vector141
vector141:
  pushl $0
801071e1:	6a 00                	push   $0x0
  pushl $141
801071e3:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801071e8:	e9 94 f4 ff ff       	jmp    80106681 <alltraps>

801071ed <vector142>:
.globl vector142
vector142:
  pushl $0
801071ed:	6a 00                	push   $0x0
  pushl $142
801071ef:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801071f4:	e9 88 f4 ff ff       	jmp    80106681 <alltraps>

801071f9 <vector143>:
.globl vector143
vector143:
  pushl $0
801071f9:	6a 00                	push   $0x0
  pushl $143
801071fb:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107200:	e9 7c f4 ff ff       	jmp    80106681 <alltraps>

80107205 <vector144>:
.globl vector144
vector144:
  pushl $0
80107205:	6a 00                	push   $0x0
  pushl $144
80107207:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010720c:	e9 70 f4 ff ff       	jmp    80106681 <alltraps>

80107211 <vector145>:
.globl vector145
vector145:
  pushl $0
80107211:	6a 00                	push   $0x0
  pushl $145
80107213:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107218:	e9 64 f4 ff ff       	jmp    80106681 <alltraps>

8010721d <vector146>:
.globl vector146
vector146:
  pushl $0
8010721d:	6a 00                	push   $0x0
  pushl $146
8010721f:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107224:	e9 58 f4 ff ff       	jmp    80106681 <alltraps>

80107229 <vector147>:
.globl vector147
vector147:
  pushl $0
80107229:	6a 00                	push   $0x0
  pushl $147
8010722b:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107230:	e9 4c f4 ff ff       	jmp    80106681 <alltraps>

80107235 <vector148>:
.globl vector148
vector148:
  pushl $0
80107235:	6a 00                	push   $0x0
  pushl $148
80107237:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010723c:	e9 40 f4 ff ff       	jmp    80106681 <alltraps>

80107241 <vector149>:
.globl vector149
vector149:
  pushl $0
80107241:	6a 00                	push   $0x0
  pushl $149
80107243:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107248:	e9 34 f4 ff ff       	jmp    80106681 <alltraps>

8010724d <vector150>:
.globl vector150
vector150:
  pushl $0
8010724d:	6a 00                	push   $0x0
  pushl $150
8010724f:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107254:	e9 28 f4 ff ff       	jmp    80106681 <alltraps>

80107259 <vector151>:
.globl vector151
vector151:
  pushl $0
80107259:	6a 00                	push   $0x0
  pushl $151
8010725b:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107260:	e9 1c f4 ff ff       	jmp    80106681 <alltraps>

80107265 <vector152>:
.globl vector152
vector152:
  pushl $0
80107265:	6a 00                	push   $0x0
  pushl $152
80107267:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010726c:	e9 10 f4 ff ff       	jmp    80106681 <alltraps>

80107271 <vector153>:
.globl vector153
vector153:
  pushl $0
80107271:	6a 00                	push   $0x0
  pushl $153
80107273:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107278:	e9 04 f4 ff ff       	jmp    80106681 <alltraps>

8010727d <vector154>:
.globl vector154
vector154:
  pushl $0
8010727d:	6a 00                	push   $0x0
  pushl $154
8010727f:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107284:	e9 f8 f3 ff ff       	jmp    80106681 <alltraps>

80107289 <vector155>:
.globl vector155
vector155:
  pushl $0
80107289:	6a 00                	push   $0x0
  pushl $155
8010728b:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107290:	e9 ec f3 ff ff       	jmp    80106681 <alltraps>

80107295 <vector156>:
.globl vector156
vector156:
  pushl $0
80107295:	6a 00                	push   $0x0
  pushl $156
80107297:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010729c:	e9 e0 f3 ff ff       	jmp    80106681 <alltraps>

801072a1 <vector157>:
.globl vector157
vector157:
  pushl $0
801072a1:	6a 00                	push   $0x0
  pushl $157
801072a3:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801072a8:	e9 d4 f3 ff ff       	jmp    80106681 <alltraps>

801072ad <vector158>:
.globl vector158
vector158:
  pushl $0
801072ad:	6a 00                	push   $0x0
  pushl $158
801072af:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801072b4:	e9 c8 f3 ff ff       	jmp    80106681 <alltraps>

801072b9 <vector159>:
.globl vector159
vector159:
  pushl $0
801072b9:	6a 00                	push   $0x0
  pushl $159
801072bb:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801072c0:	e9 bc f3 ff ff       	jmp    80106681 <alltraps>

801072c5 <vector160>:
.globl vector160
vector160:
  pushl $0
801072c5:	6a 00                	push   $0x0
  pushl $160
801072c7:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801072cc:	e9 b0 f3 ff ff       	jmp    80106681 <alltraps>

801072d1 <vector161>:
.globl vector161
vector161:
  pushl $0
801072d1:	6a 00                	push   $0x0
  pushl $161
801072d3:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801072d8:	e9 a4 f3 ff ff       	jmp    80106681 <alltraps>

801072dd <vector162>:
.globl vector162
vector162:
  pushl $0
801072dd:	6a 00                	push   $0x0
  pushl $162
801072df:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801072e4:	e9 98 f3 ff ff       	jmp    80106681 <alltraps>

801072e9 <vector163>:
.globl vector163
vector163:
  pushl $0
801072e9:	6a 00                	push   $0x0
  pushl $163
801072eb:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801072f0:	e9 8c f3 ff ff       	jmp    80106681 <alltraps>

801072f5 <vector164>:
.globl vector164
vector164:
  pushl $0
801072f5:	6a 00                	push   $0x0
  pushl $164
801072f7:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801072fc:	e9 80 f3 ff ff       	jmp    80106681 <alltraps>

80107301 <vector165>:
.globl vector165
vector165:
  pushl $0
80107301:	6a 00                	push   $0x0
  pushl $165
80107303:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107308:	e9 74 f3 ff ff       	jmp    80106681 <alltraps>

8010730d <vector166>:
.globl vector166
vector166:
  pushl $0
8010730d:	6a 00                	push   $0x0
  pushl $166
8010730f:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107314:	e9 68 f3 ff ff       	jmp    80106681 <alltraps>

80107319 <vector167>:
.globl vector167
vector167:
  pushl $0
80107319:	6a 00                	push   $0x0
  pushl $167
8010731b:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107320:	e9 5c f3 ff ff       	jmp    80106681 <alltraps>

80107325 <vector168>:
.globl vector168
vector168:
  pushl $0
80107325:	6a 00                	push   $0x0
  pushl $168
80107327:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010732c:	e9 50 f3 ff ff       	jmp    80106681 <alltraps>

80107331 <vector169>:
.globl vector169
vector169:
  pushl $0
80107331:	6a 00                	push   $0x0
  pushl $169
80107333:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107338:	e9 44 f3 ff ff       	jmp    80106681 <alltraps>

8010733d <vector170>:
.globl vector170
vector170:
  pushl $0
8010733d:	6a 00                	push   $0x0
  pushl $170
8010733f:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107344:	e9 38 f3 ff ff       	jmp    80106681 <alltraps>

80107349 <vector171>:
.globl vector171
vector171:
  pushl $0
80107349:	6a 00                	push   $0x0
  pushl $171
8010734b:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107350:	e9 2c f3 ff ff       	jmp    80106681 <alltraps>

80107355 <vector172>:
.globl vector172
vector172:
  pushl $0
80107355:	6a 00                	push   $0x0
  pushl $172
80107357:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010735c:	e9 20 f3 ff ff       	jmp    80106681 <alltraps>

80107361 <vector173>:
.globl vector173
vector173:
  pushl $0
80107361:	6a 00                	push   $0x0
  pushl $173
80107363:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107368:	e9 14 f3 ff ff       	jmp    80106681 <alltraps>

8010736d <vector174>:
.globl vector174
vector174:
  pushl $0
8010736d:	6a 00                	push   $0x0
  pushl $174
8010736f:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107374:	e9 08 f3 ff ff       	jmp    80106681 <alltraps>

80107379 <vector175>:
.globl vector175
vector175:
  pushl $0
80107379:	6a 00                	push   $0x0
  pushl $175
8010737b:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107380:	e9 fc f2 ff ff       	jmp    80106681 <alltraps>

80107385 <vector176>:
.globl vector176
vector176:
  pushl $0
80107385:	6a 00                	push   $0x0
  pushl $176
80107387:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010738c:	e9 f0 f2 ff ff       	jmp    80106681 <alltraps>

80107391 <vector177>:
.globl vector177
vector177:
  pushl $0
80107391:	6a 00                	push   $0x0
  pushl $177
80107393:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107398:	e9 e4 f2 ff ff       	jmp    80106681 <alltraps>

8010739d <vector178>:
.globl vector178
vector178:
  pushl $0
8010739d:	6a 00                	push   $0x0
  pushl $178
8010739f:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801073a4:	e9 d8 f2 ff ff       	jmp    80106681 <alltraps>

801073a9 <vector179>:
.globl vector179
vector179:
  pushl $0
801073a9:	6a 00                	push   $0x0
  pushl $179
801073ab:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801073b0:	e9 cc f2 ff ff       	jmp    80106681 <alltraps>

801073b5 <vector180>:
.globl vector180
vector180:
  pushl $0
801073b5:	6a 00                	push   $0x0
  pushl $180
801073b7:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801073bc:	e9 c0 f2 ff ff       	jmp    80106681 <alltraps>

801073c1 <vector181>:
.globl vector181
vector181:
  pushl $0
801073c1:	6a 00                	push   $0x0
  pushl $181
801073c3:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801073c8:	e9 b4 f2 ff ff       	jmp    80106681 <alltraps>

801073cd <vector182>:
.globl vector182
vector182:
  pushl $0
801073cd:	6a 00                	push   $0x0
  pushl $182
801073cf:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801073d4:	e9 a8 f2 ff ff       	jmp    80106681 <alltraps>

801073d9 <vector183>:
.globl vector183
vector183:
  pushl $0
801073d9:	6a 00                	push   $0x0
  pushl $183
801073db:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801073e0:	e9 9c f2 ff ff       	jmp    80106681 <alltraps>

801073e5 <vector184>:
.globl vector184
vector184:
  pushl $0
801073e5:	6a 00                	push   $0x0
  pushl $184
801073e7:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801073ec:	e9 90 f2 ff ff       	jmp    80106681 <alltraps>

801073f1 <vector185>:
.globl vector185
vector185:
  pushl $0
801073f1:	6a 00                	push   $0x0
  pushl $185
801073f3:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801073f8:	e9 84 f2 ff ff       	jmp    80106681 <alltraps>

801073fd <vector186>:
.globl vector186
vector186:
  pushl $0
801073fd:	6a 00                	push   $0x0
  pushl $186
801073ff:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107404:	e9 78 f2 ff ff       	jmp    80106681 <alltraps>

80107409 <vector187>:
.globl vector187
vector187:
  pushl $0
80107409:	6a 00                	push   $0x0
  pushl $187
8010740b:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107410:	e9 6c f2 ff ff       	jmp    80106681 <alltraps>

80107415 <vector188>:
.globl vector188
vector188:
  pushl $0
80107415:	6a 00                	push   $0x0
  pushl $188
80107417:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010741c:	e9 60 f2 ff ff       	jmp    80106681 <alltraps>

80107421 <vector189>:
.globl vector189
vector189:
  pushl $0
80107421:	6a 00                	push   $0x0
  pushl $189
80107423:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107428:	e9 54 f2 ff ff       	jmp    80106681 <alltraps>

8010742d <vector190>:
.globl vector190
vector190:
  pushl $0
8010742d:	6a 00                	push   $0x0
  pushl $190
8010742f:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107434:	e9 48 f2 ff ff       	jmp    80106681 <alltraps>

80107439 <vector191>:
.globl vector191
vector191:
  pushl $0
80107439:	6a 00                	push   $0x0
  pushl $191
8010743b:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107440:	e9 3c f2 ff ff       	jmp    80106681 <alltraps>

80107445 <vector192>:
.globl vector192
vector192:
  pushl $0
80107445:	6a 00                	push   $0x0
  pushl $192
80107447:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010744c:	e9 30 f2 ff ff       	jmp    80106681 <alltraps>

80107451 <vector193>:
.globl vector193
vector193:
  pushl $0
80107451:	6a 00                	push   $0x0
  pushl $193
80107453:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107458:	e9 24 f2 ff ff       	jmp    80106681 <alltraps>

8010745d <vector194>:
.globl vector194
vector194:
  pushl $0
8010745d:	6a 00                	push   $0x0
  pushl $194
8010745f:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107464:	e9 18 f2 ff ff       	jmp    80106681 <alltraps>

80107469 <vector195>:
.globl vector195
vector195:
  pushl $0
80107469:	6a 00                	push   $0x0
  pushl $195
8010746b:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107470:	e9 0c f2 ff ff       	jmp    80106681 <alltraps>

80107475 <vector196>:
.globl vector196
vector196:
  pushl $0
80107475:	6a 00                	push   $0x0
  pushl $196
80107477:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010747c:	e9 00 f2 ff ff       	jmp    80106681 <alltraps>

80107481 <vector197>:
.globl vector197
vector197:
  pushl $0
80107481:	6a 00                	push   $0x0
  pushl $197
80107483:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107488:	e9 f4 f1 ff ff       	jmp    80106681 <alltraps>

8010748d <vector198>:
.globl vector198
vector198:
  pushl $0
8010748d:	6a 00                	push   $0x0
  pushl $198
8010748f:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107494:	e9 e8 f1 ff ff       	jmp    80106681 <alltraps>

80107499 <vector199>:
.globl vector199
vector199:
  pushl $0
80107499:	6a 00                	push   $0x0
  pushl $199
8010749b:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801074a0:	e9 dc f1 ff ff       	jmp    80106681 <alltraps>

801074a5 <vector200>:
.globl vector200
vector200:
  pushl $0
801074a5:	6a 00                	push   $0x0
  pushl $200
801074a7:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801074ac:	e9 d0 f1 ff ff       	jmp    80106681 <alltraps>

801074b1 <vector201>:
.globl vector201
vector201:
  pushl $0
801074b1:	6a 00                	push   $0x0
  pushl $201
801074b3:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801074b8:	e9 c4 f1 ff ff       	jmp    80106681 <alltraps>

801074bd <vector202>:
.globl vector202
vector202:
  pushl $0
801074bd:	6a 00                	push   $0x0
  pushl $202
801074bf:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801074c4:	e9 b8 f1 ff ff       	jmp    80106681 <alltraps>

801074c9 <vector203>:
.globl vector203
vector203:
  pushl $0
801074c9:	6a 00                	push   $0x0
  pushl $203
801074cb:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801074d0:	e9 ac f1 ff ff       	jmp    80106681 <alltraps>

801074d5 <vector204>:
.globl vector204
vector204:
  pushl $0
801074d5:	6a 00                	push   $0x0
  pushl $204
801074d7:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801074dc:	e9 a0 f1 ff ff       	jmp    80106681 <alltraps>

801074e1 <vector205>:
.globl vector205
vector205:
  pushl $0
801074e1:	6a 00                	push   $0x0
  pushl $205
801074e3:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801074e8:	e9 94 f1 ff ff       	jmp    80106681 <alltraps>

801074ed <vector206>:
.globl vector206
vector206:
  pushl $0
801074ed:	6a 00                	push   $0x0
  pushl $206
801074ef:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801074f4:	e9 88 f1 ff ff       	jmp    80106681 <alltraps>

801074f9 <vector207>:
.globl vector207
vector207:
  pushl $0
801074f9:	6a 00                	push   $0x0
  pushl $207
801074fb:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107500:	e9 7c f1 ff ff       	jmp    80106681 <alltraps>

80107505 <vector208>:
.globl vector208
vector208:
  pushl $0
80107505:	6a 00                	push   $0x0
  pushl $208
80107507:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010750c:	e9 70 f1 ff ff       	jmp    80106681 <alltraps>

80107511 <vector209>:
.globl vector209
vector209:
  pushl $0
80107511:	6a 00                	push   $0x0
  pushl $209
80107513:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107518:	e9 64 f1 ff ff       	jmp    80106681 <alltraps>

8010751d <vector210>:
.globl vector210
vector210:
  pushl $0
8010751d:	6a 00                	push   $0x0
  pushl $210
8010751f:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107524:	e9 58 f1 ff ff       	jmp    80106681 <alltraps>

80107529 <vector211>:
.globl vector211
vector211:
  pushl $0
80107529:	6a 00                	push   $0x0
  pushl $211
8010752b:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107530:	e9 4c f1 ff ff       	jmp    80106681 <alltraps>

80107535 <vector212>:
.globl vector212
vector212:
  pushl $0
80107535:	6a 00                	push   $0x0
  pushl $212
80107537:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010753c:	e9 40 f1 ff ff       	jmp    80106681 <alltraps>

80107541 <vector213>:
.globl vector213
vector213:
  pushl $0
80107541:	6a 00                	push   $0x0
  pushl $213
80107543:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107548:	e9 34 f1 ff ff       	jmp    80106681 <alltraps>

8010754d <vector214>:
.globl vector214
vector214:
  pushl $0
8010754d:	6a 00                	push   $0x0
  pushl $214
8010754f:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107554:	e9 28 f1 ff ff       	jmp    80106681 <alltraps>

80107559 <vector215>:
.globl vector215
vector215:
  pushl $0
80107559:	6a 00                	push   $0x0
  pushl $215
8010755b:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107560:	e9 1c f1 ff ff       	jmp    80106681 <alltraps>

80107565 <vector216>:
.globl vector216
vector216:
  pushl $0
80107565:	6a 00                	push   $0x0
  pushl $216
80107567:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010756c:	e9 10 f1 ff ff       	jmp    80106681 <alltraps>

80107571 <vector217>:
.globl vector217
vector217:
  pushl $0
80107571:	6a 00                	push   $0x0
  pushl $217
80107573:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107578:	e9 04 f1 ff ff       	jmp    80106681 <alltraps>

8010757d <vector218>:
.globl vector218
vector218:
  pushl $0
8010757d:	6a 00                	push   $0x0
  pushl $218
8010757f:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107584:	e9 f8 f0 ff ff       	jmp    80106681 <alltraps>

80107589 <vector219>:
.globl vector219
vector219:
  pushl $0
80107589:	6a 00                	push   $0x0
  pushl $219
8010758b:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107590:	e9 ec f0 ff ff       	jmp    80106681 <alltraps>

80107595 <vector220>:
.globl vector220
vector220:
  pushl $0
80107595:	6a 00                	push   $0x0
  pushl $220
80107597:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010759c:	e9 e0 f0 ff ff       	jmp    80106681 <alltraps>

801075a1 <vector221>:
.globl vector221
vector221:
  pushl $0
801075a1:	6a 00                	push   $0x0
  pushl $221
801075a3:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801075a8:	e9 d4 f0 ff ff       	jmp    80106681 <alltraps>

801075ad <vector222>:
.globl vector222
vector222:
  pushl $0
801075ad:	6a 00                	push   $0x0
  pushl $222
801075af:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801075b4:	e9 c8 f0 ff ff       	jmp    80106681 <alltraps>

801075b9 <vector223>:
.globl vector223
vector223:
  pushl $0
801075b9:	6a 00                	push   $0x0
  pushl $223
801075bb:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801075c0:	e9 bc f0 ff ff       	jmp    80106681 <alltraps>

801075c5 <vector224>:
.globl vector224
vector224:
  pushl $0
801075c5:	6a 00                	push   $0x0
  pushl $224
801075c7:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801075cc:	e9 b0 f0 ff ff       	jmp    80106681 <alltraps>

801075d1 <vector225>:
.globl vector225
vector225:
  pushl $0
801075d1:	6a 00                	push   $0x0
  pushl $225
801075d3:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801075d8:	e9 a4 f0 ff ff       	jmp    80106681 <alltraps>

801075dd <vector226>:
.globl vector226
vector226:
  pushl $0
801075dd:	6a 00                	push   $0x0
  pushl $226
801075df:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801075e4:	e9 98 f0 ff ff       	jmp    80106681 <alltraps>

801075e9 <vector227>:
.globl vector227
vector227:
  pushl $0
801075e9:	6a 00                	push   $0x0
  pushl $227
801075eb:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801075f0:	e9 8c f0 ff ff       	jmp    80106681 <alltraps>

801075f5 <vector228>:
.globl vector228
vector228:
  pushl $0
801075f5:	6a 00                	push   $0x0
  pushl $228
801075f7:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801075fc:	e9 80 f0 ff ff       	jmp    80106681 <alltraps>

80107601 <vector229>:
.globl vector229
vector229:
  pushl $0
80107601:	6a 00                	push   $0x0
  pushl $229
80107603:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107608:	e9 74 f0 ff ff       	jmp    80106681 <alltraps>

8010760d <vector230>:
.globl vector230
vector230:
  pushl $0
8010760d:	6a 00                	push   $0x0
  pushl $230
8010760f:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107614:	e9 68 f0 ff ff       	jmp    80106681 <alltraps>

80107619 <vector231>:
.globl vector231
vector231:
  pushl $0
80107619:	6a 00                	push   $0x0
  pushl $231
8010761b:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107620:	e9 5c f0 ff ff       	jmp    80106681 <alltraps>

80107625 <vector232>:
.globl vector232
vector232:
  pushl $0
80107625:	6a 00                	push   $0x0
  pushl $232
80107627:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010762c:	e9 50 f0 ff ff       	jmp    80106681 <alltraps>

80107631 <vector233>:
.globl vector233
vector233:
  pushl $0
80107631:	6a 00                	push   $0x0
  pushl $233
80107633:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107638:	e9 44 f0 ff ff       	jmp    80106681 <alltraps>

8010763d <vector234>:
.globl vector234
vector234:
  pushl $0
8010763d:	6a 00                	push   $0x0
  pushl $234
8010763f:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107644:	e9 38 f0 ff ff       	jmp    80106681 <alltraps>

80107649 <vector235>:
.globl vector235
vector235:
  pushl $0
80107649:	6a 00                	push   $0x0
  pushl $235
8010764b:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107650:	e9 2c f0 ff ff       	jmp    80106681 <alltraps>

80107655 <vector236>:
.globl vector236
vector236:
  pushl $0
80107655:	6a 00                	push   $0x0
  pushl $236
80107657:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010765c:	e9 20 f0 ff ff       	jmp    80106681 <alltraps>

80107661 <vector237>:
.globl vector237
vector237:
  pushl $0
80107661:	6a 00                	push   $0x0
  pushl $237
80107663:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107668:	e9 14 f0 ff ff       	jmp    80106681 <alltraps>

8010766d <vector238>:
.globl vector238
vector238:
  pushl $0
8010766d:	6a 00                	push   $0x0
  pushl $238
8010766f:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107674:	e9 08 f0 ff ff       	jmp    80106681 <alltraps>

80107679 <vector239>:
.globl vector239
vector239:
  pushl $0
80107679:	6a 00                	push   $0x0
  pushl $239
8010767b:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107680:	e9 fc ef ff ff       	jmp    80106681 <alltraps>

80107685 <vector240>:
.globl vector240
vector240:
  pushl $0
80107685:	6a 00                	push   $0x0
  pushl $240
80107687:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010768c:	e9 f0 ef ff ff       	jmp    80106681 <alltraps>

80107691 <vector241>:
.globl vector241
vector241:
  pushl $0
80107691:	6a 00                	push   $0x0
  pushl $241
80107693:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107698:	e9 e4 ef ff ff       	jmp    80106681 <alltraps>

8010769d <vector242>:
.globl vector242
vector242:
  pushl $0
8010769d:	6a 00                	push   $0x0
  pushl $242
8010769f:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801076a4:	e9 d8 ef ff ff       	jmp    80106681 <alltraps>

801076a9 <vector243>:
.globl vector243
vector243:
  pushl $0
801076a9:	6a 00                	push   $0x0
  pushl $243
801076ab:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801076b0:	e9 cc ef ff ff       	jmp    80106681 <alltraps>

801076b5 <vector244>:
.globl vector244
vector244:
  pushl $0
801076b5:	6a 00                	push   $0x0
  pushl $244
801076b7:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801076bc:	e9 c0 ef ff ff       	jmp    80106681 <alltraps>

801076c1 <vector245>:
.globl vector245
vector245:
  pushl $0
801076c1:	6a 00                	push   $0x0
  pushl $245
801076c3:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801076c8:	e9 b4 ef ff ff       	jmp    80106681 <alltraps>

801076cd <vector246>:
.globl vector246
vector246:
  pushl $0
801076cd:	6a 00                	push   $0x0
  pushl $246
801076cf:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801076d4:	e9 a8 ef ff ff       	jmp    80106681 <alltraps>

801076d9 <vector247>:
.globl vector247
vector247:
  pushl $0
801076d9:	6a 00                	push   $0x0
  pushl $247
801076db:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801076e0:	e9 9c ef ff ff       	jmp    80106681 <alltraps>

801076e5 <vector248>:
.globl vector248
vector248:
  pushl $0
801076e5:	6a 00                	push   $0x0
  pushl $248
801076e7:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801076ec:	e9 90 ef ff ff       	jmp    80106681 <alltraps>

801076f1 <vector249>:
.globl vector249
vector249:
  pushl $0
801076f1:	6a 00                	push   $0x0
  pushl $249
801076f3:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801076f8:	e9 84 ef ff ff       	jmp    80106681 <alltraps>

801076fd <vector250>:
.globl vector250
vector250:
  pushl $0
801076fd:	6a 00                	push   $0x0
  pushl $250
801076ff:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107704:	e9 78 ef ff ff       	jmp    80106681 <alltraps>

80107709 <vector251>:
.globl vector251
vector251:
  pushl $0
80107709:	6a 00                	push   $0x0
  pushl $251
8010770b:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107710:	e9 6c ef ff ff       	jmp    80106681 <alltraps>

80107715 <vector252>:
.globl vector252
vector252:
  pushl $0
80107715:	6a 00                	push   $0x0
  pushl $252
80107717:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010771c:	e9 60 ef ff ff       	jmp    80106681 <alltraps>

80107721 <vector253>:
.globl vector253
vector253:
  pushl $0
80107721:	6a 00                	push   $0x0
  pushl $253
80107723:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107728:	e9 54 ef ff ff       	jmp    80106681 <alltraps>

8010772d <vector254>:
.globl vector254
vector254:
  pushl $0
8010772d:	6a 00                	push   $0x0
  pushl $254
8010772f:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107734:	e9 48 ef ff ff       	jmp    80106681 <alltraps>

80107739 <vector255>:
.globl vector255
vector255:
  pushl $0
80107739:	6a 00                	push   $0x0
  pushl $255
8010773b:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107740:	e9 3c ef ff ff       	jmp    80106681 <alltraps>

80107745 <lgdt>:
{
80107745:	55                   	push   %ebp
80107746:	89 e5                	mov    %esp,%ebp
80107748:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010774b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010774e:	83 e8 01             	sub    $0x1,%eax
80107751:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107755:	8b 45 08             	mov    0x8(%ebp),%eax
80107758:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010775c:	8b 45 08             	mov    0x8(%ebp),%eax
8010775f:	c1 e8 10             	shr    $0x10,%eax
80107762:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107766:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107769:	0f 01 10             	lgdtl  (%eax)
}
8010776c:	90                   	nop
8010776d:	c9                   	leave
8010776e:	c3                   	ret

8010776f <ltr>:
{
8010776f:	55                   	push   %ebp
80107770:	89 e5                	mov    %esp,%ebp
80107772:	83 ec 04             	sub    $0x4,%esp
80107775:	8b 45 08             	mov    0x8(%ebp),%eax
80107778:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010777c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107780:	0f 00 d8             	ltr    %eax
}
80107783:	90                   	nop
80107784:	c9                   	leave
80107785:	c3                   	ret

80107786 <loadgs>:
{
80107786:	55                   	push   %ebp
80107787:	89 e5                	mov    %esp,%ebp
80107789:	83 ec 04             	sub    $0x4,%esp
8010778c:	8b 45 08             	mov    0x8(%ebp),%eax
8010778f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107793:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107797:	8e e8                	mov    %eax,%gs
}
80107799:	90                   	nop
8010779a:	c9                   	leave
8010779b:	c3                   	ret

8010779c <lcr3>:
{
8010779c:	55                   	push   %ebp
8010779d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010779f:	8b 45 08             	mov    0x8(%ebp),%eax
801077a2:	0f 22 d8             	mov    %eax,%cr3
}
801077a5:	90                   	nop
801077a6:	5d                   	pop    %ebp
801077a7:	c3                   	ret

801077a8 <v2p>:
static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801077a8:	55                   	push   %ebp
801077a9:	89 e5                	mov    %esp,%ebp
801077ab:	8b 45 08             	mov    0x8(%ebp),%eax
801077ae:	05 00 00 00 80       	add    $0x80000000,%eax
801077b3:	5d                   	pop    %ebp
801077b4:	c3                   	ret

801077b5 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801077b5:	55                   	push   %ebp
801077b6:	89 e5                	mov    %esp,%ebp
801077b8:	8b 45 08             	mov    0x8(%ebp),%eax
801077bb:	05 00 00 00 80       	add    $0x80000000,%eax
801077c0:	5d                   	pop    %ebp
801077c1:	c3                   	ret

801077c2 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801077c2:	55                   	push   %ebp
801077c3:	89 e5                	mov    %esp,%ebp
801077c5:	53                   	push   %ebx
801077c6:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801077c9:	e8 0f b8 ff ff       	call   80102fdd <cpunum>
801077ce:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801077d4:	05 20 13 11 80       	add    $0x80111320,%eax
801077d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801077dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077df:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801077e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e8:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801077ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f1:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801077f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801077fc:	83 e2 f0             	and    $0xfffffff0,%edx
801077ff:	83 ca 0a             	or     $0xa,%edx
80107802:	88 50 7d             	mov    %dl,0x7d(%eax)
80107805:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107808:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010780c:	83 ca 10             	or     $0x10,%edx
8010780f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107812:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107815:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107819:	83 e2 9f             	and    $0xffffff9f,%edx
8010781c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010781f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107822:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107826:	83 ca 80             	or     $0xffffff80,%edx
80107829:	88 50 7d             	mov    %dl,0x7d(%eax)
8010782c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107833:	83 ca 0f             	or     $0xf,%edx
80107836:	88 50 7e             	mov    %dl,0x7e(%eax)
80107839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107840:	83 e2 ef             	and    $0xffffffef,%edx
80107843:	88 50 7e             	mov    %dl,0x7e(%eax)
80107846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107849:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010784d:	83 e2 df             	and    $0xffffffdf,%edx
80107850:	88 50 7e             	mov    %dl,0x7e(%eax)
80107853:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107856:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010785a:	83 ca 40             	or     $0x40,%edx
8010785d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107860:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107863:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107867:	83 ca 80             	or     $0xffffff80,%edx
8010786a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010786d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107870:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107874:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107877:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010787e:	ff ff 
80107880:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107883:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010788a:	00 00 
8010788c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788f:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107899:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078a0:	83 e2 f0             	and    $0xfffffff0,%edx
801078a3:	83 ca 02             	or     $0x2,%edx
801078a6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078af:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078b6:	83 ca 10             	or     $0x10,%edx
801078b9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078c9:	83 e2 9f             	and    $0xffffff9f,%edx
801078cc:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078dc:	83 ca 80             	or     $0xffffff80,%edx
801078df:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e8:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801078ef:	83 ca 0f             	or     $0xf,%edx
801078f2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fb:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107902:	83 e2 ef             	and    $0xffffffef,%edx
80107905:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010790b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107915:	83 e2 df             	and    $0xffffffdf,%edx
80107918:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010791e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107921:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107928:	83 ca 40             	or     $0x40,%edx
8010792b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107934:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010793b:	83 ca 80             	or     $0xffffff80,%edx
8010793e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107944:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107947:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010794e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107951:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107958:	ff ff 
8010795a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795d:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107964:	00 00 
80107966:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107969:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107973:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010797a:	83 e2 f0             	and    $0xfffffff0,%edx
8010797d:	83 ca 0a             	or     $0xa,%edx
80107980:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107989:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107990:	83 ca 10             	or     $0x10,%edx
80107993:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079a3:	83 ca 60             	or     $0x60,%edx
801079a6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079af:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079b6:	83 ca 80             	or     $0xffffff80,%edx
801079b9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801079c9:	83 ca 0f             	or     $0xf,%edx
801079cc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801079d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801079dc:	83 e2 ef             	and    $0xffffffef,%edx
801079df:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801079e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801079ef:	83 e2 df             	and    $0xffffffdf,%edx
801079f2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801079f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079fb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a02:	83 ca 40             	or     $0x40,%edx
80107a05:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a15:	83 ca 80             	or     $0xffffff80,%edx
80107a18:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a21:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2b:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107a32:	ff ff 
80107a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a37:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107a3e:	00 00 
80107a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a43:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4d:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a54:	83 e2 f0             	and    $0xfffffff0,%edx
80107a57:	83 ca 02             	or     $0x2,%edx
80107a5a:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a63:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a6a:	83 ca 10             	or     $0x10,%edx
80107a6d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a76:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a7d:	83 ca 60             	or     $0x60,%edx
80107a80:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a89:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a90:	83 ca 80             	or     $0xffffff80,%edx
80107a93:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9c:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107aa3:	83 ca 0f             	or     $0xf,%edx
80107aa6:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aaf:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107ab6:	83 e2 ef             	and    $0xffffffef,%edx
80107ab9:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac2:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107ac9:	83 e2 df             	and    $0xffffffdf,%edx
80107acc:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad5:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107adc:	83 ca 40             	or     $0x40,%edx
80107adf:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae8:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107aef:	83 ca 80             	or     $0xffffff80,%edx
80107af2:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afb:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b05:	05 b4 00 00 00       	add    $0xb4,%eax
80107b0a:	89 c3                	mov    %eax,%ebx
80107b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0f:	05 b4 00 00 00       	add    $0xb4,%eax
80107b14:	c1 e8 10             	shr    $0x10,%eax
80107b17:	89 c2                	mov    %eax,%edx
80107b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1c:	05 b4 00 00 00       	add    $0xb4,%eax
80107b21:	c1 e8 18             	shr    $0x18,%eax
80107b24:	89 c1                	mov    %eax,%ecx
80107b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b29:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107b30:	00 00 
80107b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b35:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3f:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80107b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b48:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b4f:	83 e2 f0             	and    $0xfffffff0,%edx
80107b52:	83 ca 02             	or     $0x2,%edx
80107b55:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b65:	83 ca 10             	or     $0x10,%edx
80107b68:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b71:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b78:	83 e2 9f             	and    $0xffffff9f,%edx
80107b7b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b84:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b8b:	83 ca 80             	or     $0xffffff80,%edx
80107b8e:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b97:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b9e:	83 e2 f0             	and    $0xfffffff0,%edx
80107ba1:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107baa:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107bb1:	83 e2 ef             	and    $0xffffffef,%edx
80107bb4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbd:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107bc4:	83 e2 df             	and    $0xffffffdf,%edx
80107bc7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd0:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107bd7:	83 ca 40             	or     $0x40,%edx
80107bda:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be3:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107bea:	83 ca 80             	or     $0xffffff80,%edx
80107bed:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf6:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bff:	83 c0 70             	add    $0x70,%eax
80107c02:	83 ec 08             	sub    $0x8,%esp
80107c05:	6a 38                	push   $0x38
80107c07:	50                   	push   %eax
80107c08:	e8 38 fb ff ff       	call   80107745 <lgdt>
80107c0d:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80107c10:	83 ec 0c             	sub    $0xc,%esp
80107c13:	6a 18                	push   $0x18
80107c15:	e8 6c fb ff ff       	call   80107786 <loadgs>
80107c1a:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80107c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c20:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107c26:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107c2d:	00 00 00 00 
}
80107c31:	90                   	nop
80107c32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107c35:	c9                   	leave
80107c36:	c3                   	ret

80107c37 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107c37:	55                   	push   %ebp
80107c38:	89 e5                	mov    %esp,%ebp
80107c3a:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107c3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c40:	c1 e8 16             	shr    $0x16,%eax
80107c43:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c4a:	8b 45 08             	mov    0x8(%ebp),%eax
80107c4d:	01 d0                	add    %edx,%eax
80107c4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107c52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c55:	8b 00                	mov    (%eax),%eax
80107c57:	83 e0 01             	and    $0x1,%eax
80107c5a:	85 c0                	test   %eax,%eax
80107c5c:	74 18                	je     80107c76 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107c5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c61:	8b 00                	mov    (%eax),%eax
80107c63:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c68:	50                   	push   %eax
80107c69:	e8 47 fb ff ff       	call   801077b5 <p2v>
80107c6e:	83 c4 04             	add    $0x4,%esp
80107c71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c74:	eb 48                	jmp    80107cbe <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107c76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107c7a:	74 0e                	je     80107c8a <walkpgdir+0x53>
80107c7c:	e8 f8 af ff ff       	call   80102c79 <kalloc>
80107c81:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c84:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c88:	75 07                	jne    80107c91 <walkpgdir+0x5a>
      return 0;
80107c8a:	b8 00 00 00 00       	mov    $0x0,%eax
80107c8f:	eb 44                	jmp    80107cd5 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107c91:	83 ec 04             	sub    $0x4,%esp
80107c94:	68 00 10 00 00       	push   $0x1000
80107c99:	6a 00                	push   $0x0
80107c9b:	ff 75 f4             	push   -0xc(%ebp)
80107c9e:	e8 23 d6 ff ff       	call   801052c6 <memset>
80107ca3:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107ca6:	83 ec 0c             	sub    $0xc,%esp
80107ca9:	ff 75 f4             	push   -0xc(%ebp)
80107cac:	e8 f7 fa ff ff       	call   801077a8 <v2p>
80107cb1:	83 c4 10             	add    $0x10,%esp
80107cb4:	83 c8 07             	or     $0x7,%eax
80107cb7:	89 c2                	mov    %eax,%edx
80107cb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cbc:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107cbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cc1:	c1 e8 0c             	shr    $0xc,%eax
80107cc4:	25 ff 03 00 00       	and    $0x3ff,%eax
80107cc9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd3:	01 d0                	add    %edx,%eax
}
80107cd5:	c9                   	leave
80107cd6:	c3                   	ret

80107cd7 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107cd7:	55                   	push   %ebp
80107cd8:	89 e5                	mov    %esp,%ebp
80107cda:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ce0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ce5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107ce8:	8b 55 0c             	mov    0xc(%ebp),%edx
80107ceb:	8b 45 10             	mov    0x10(%ebp),%eax
80107cee:	01 d0                	add    %edx,%eax
80107cf0:	83 e8 01             	sub    $0x1,%eax
80107cf3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cf8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107cfb:	83 ec 04             	sub    $0x4,%esp
80107cfe:	6a 01                	push   $0x1
80107d00:	ff 75 f4             	push   -0xc(%ebp)
80107d03:	ff 75 08             	push   0x8(%ebp)
80107d06:	e8 2c ff ff ff       	call   80107c37 <walkpgdir>
80107d0b:	83 c4 10             	add    $0x10,%esp
80107d0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d11:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d15:	75 07                	jne    80107d1e <mappages+0x47>
      return -1;
80107d17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d1c:	eb 47                	jmp    80107d65 <mappages+0x8e>
    if(*pte & PTE_P)
80107d1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d21:	8b 00                	mov    (%eax),%eax
80107d23:	83 e0 01             	and    $0x1,%eax
80107d26:	85 c0                	test   %eax,%eax
80107d28:	74 0d                	je     80107d37 <mappages+0x60>
      panic("remap");
80107d2a:	83 ec 0c             	sub    $0xc,%esp
80107d2d:	68 a0 8b 10 80       	push   $0x80108ba0
80107d32:	e8 42 88 ff ff       	call   80100579 <panic>
    *pte = pa | perm | PTE_P;
80107d37:	8b 45 18             	mov    0x18(%ebp),%eax
80107d3a:	0b 45 14             	or     0x14(%ebp),%eax
80107d3d:	83 c8 01             	or     $0x1,%eax
80107d40:	89 c2                	mov    %eax,%edx
80107d42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d45:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107d4d:	74 10                	je     80107d5f <mappages+0x88>
      break;
    a += PGSIZE;
80107d4f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107d56:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107d5d:	eb 9c                	jmp    80107cfb <mappages+0x24>
      break;
80107d5f:	90                   	nop
  }
  return 0;
80107d60:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d65:	c9                   	leave
80107d66:	c3                   	ret

80107d67 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107d67:	55                   	push   %ebp
80107d68:	89 e5                	mov    %esp,%ebp
80107d6a:	53                   	push   %ebx
80107d6b:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107d6e:	e8 06 af ff ff       	call   80102c79 <kalloc>
80107d73:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d76:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d7a:	75 0a                	jne    80107d86 <setupkvm+0x1f>
    return 0;
80107d7c:	b8 00 00 00 00       	mov    $0x0,%eax
80107d81:	e9 8e 00 00 00       	jmp    80107e14 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80107d86:	83 ec 04             	sub    $0x4,%esp
80107d89:	68 00 10 00 00       	push   $0x1000
80107d8e:	6a 00                	push   $0x0
80107d90:	ff 75 f0             	push   -0x10(%ebp)
80107d93:	e8 2e d5 ff ff       	call   801052c6 <memset>
80107d98:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107d9b:	83 ec 0c             	sub    $0xc,%esp
80107d9e:	68 00 00 00 0e       	push   $0xe000000
80107da3:	e8 0d fa ff ff       	call   801077b5 <p2v>
80107da8:	83 c4 10             	add    $0x10,%esp
80107dab:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107db0:	76 0d                	jbe    80107dbf <setupkvm+0x58>
    panic("PHYSTOP too high");
80107db2:	83 ec 0c             	sub    $0xc,%esp
80107db5:	68 a6 8b 10 80       	push   $0x80108ba6
80107dba:	e8 ba 87 ff ff       	call   80100579 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107dbf:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107dc6:	eb 40                	jmp    80107e08 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dcb:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80107dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd1:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd7:	8b 58 08             	mov    0x8(%eax),%ebx
80107dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddd:	8b 40 04             	mov    0x4(%eax),%eax
80107de0:	29 c3                	sub    %eax,%ebx
80107de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de5:	8b 00                	mov    (%eax),%eax
80107de7:	83 ec 0c             	sub    $0xc,%esp
80107dea:	51                   	push   %ecx
80107deb:	52                   	push   %edx
80107dec:	53                   	push   %ebx
80107ded:	50                   	push   %eax
80107dee:	ff 75 f0             	push   -0x10(%ebp)
80107df1:	e8 e1 fe ff ff       	call   80107cd7 <mappages>
80107df6:	83 c4 20             	add    $0x20,%esp
80107df9:	85 c0                	test   %eax,%eax
80107dfb:	79 07                	jns    80107e04 <setupkvm+0x9d>
      return 0;
80107dfd:	b8 00 00 00 00       	mov    $0x0,%eax
80107e02:	eb 10                	jmp    80107e14 <setupkvm+0xad>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107e04:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107e08:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107e0f:	72 b7                	jb     80107dc8 <setupkvm+0x61>
  return pgdir;
80107e11:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107e14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107e17:	c9                   	leave
80107e18:	c3                   	ret

80107e19 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107e19:	55                   	push   %ebp
80107e1a:	89 e5                	mov    %esp,%ebp
80107e1c:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107e1f:	e8 43 ff ff ff       	call   80107d67 <setupkvm>
80107e24:	a3 a0 40 11 80       	mov    %eax,0x801140a0
  switchkvm();
80107e29:	e8 03 00 00 00       	call   80107e31 <switchkvm>
}
80107e2e:	90                   	nop
80107e2f:	c9                   	leave
80107e30:	c3                   	ret

80107e31 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107e31:	55                   	push   %ebp
80107e32:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107e34:	a1 a0 40 11 80       	mov    0x801140a0,%eax
80107e39:	50                   	push   %eax
80107e3a:	e8 69 f9 ff ff       	call   801077a8 <v2p>
80107e3f:	83 c4 04             	add    $0x4,%esp
80107e42:	50                   	push   %eax
80107e43:	e8 54 f9 ff ff       	call   8010779c <lcr3>
80107e48:	83 c4 04             	add    $0x4,%esp
}
80107e4b:	90                   	nop
80107e4c:	c9                   	leave
80107e4d:	c3                   	ret

80107e4e <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107e4e:	55                   	push   %ebp
80107e4f:	89 e5                	mov    %esp,%ebp
80107e51:	56                   	push   %esi
80107e52:	53                   	push   %ebx
  pushcli();
80107e53:	e8 68 d3 ff ff       	call   801051c0 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107e58:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107e5e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107e65:	83 c2 08             	add    $0x8,%edx
80107e68:	89 d6                	mov    %edx,%esi
80107e6a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107e71:	83 c2 08             	add    $0x8,%edx
80107e74:	c1 ea 10             	shr    $0x10,%edx
80107e77:	89 d3                	mov    %edx,%ebx
80107e79:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107e80:	83 c2 08             	add    $0x8,%edx
80107e83:	c1 ea 18             	shr    $0x18,%edx
80107e86:	89 d1                	mov    %edx,%ecx
80107e88:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107e8f:	67 00 
80107e91:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80107e98:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80107e9e:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107ea5:	83 e2 f0             	and    $0xfffffff0,%edx
80107ea8:	83 ca 09             	or     $0x9,%edx
80107eab:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107eb1:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107eb8:	83 ca 10             	or     $0x10,%edx
80107ebb:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107ec1:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107ec8:	83 e2 9f             	and    $0xffffff9f,%edx
80107ecb:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107ed1:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107ed8:	83 ca 80             	or     $0xffffff80,%edx
80107edb:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107ee1:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107ee8:	83 e2 f0             	and    $0xfffffff0,%edx
80107eeb:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107ef1:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107ef8:	83 e2 ef             	and    $0xffffffef,%edx
80107efb:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f01:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f08:	83 e2 df             	and    $0xffffffdf,%edx
80107f0b:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f11:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f18:	83 ca 40             	or     $0x40,%edx
80107f1b:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f21:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f28:	83 e2 7f             	and    $0x7f,%edx
80107f2b:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f31:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107f37:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f3d:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f44:	83 e2 ef             	and    $0xffffffef,%edx
80107f47:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107f4d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f53:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107f59:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107f5f:	8b 40 08             	mov    0x8(%eax),%eax
80107f62:	89 c2                	mov    %eax,%edx
80107f64:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f6a:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107f70:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107f73:	83 ec 0c             	sub    $0xc,%esp
80107f76:	6a 30                	push   $0x30
80107f78:	e8 f2 f7 ff ff       	call   8010776f <ltr>
80107f7d:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80107f80:	8b 45 08             	mov    0x8(%ebp),%eax
80107f83:	8b 40 04             	mov    0x4(%eax),%eax
80107f86:	85 c0                	test   %eax,%eax
80107f88:	75 0d                	jne    80107f97 <switchuvm+0x149>
    panic("switchuvm: no pgdir");
80107f8a:	83 ec 0c             	sub    $0xc,%esp
80107f8d:	68 b7 8b 10 80       	push   $0x80108bb7
80107f92:	e8 e2 85 ff ff       	call   80100579 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107f97:	8b 45 08             	mov    0x8(%ebp),%eax
80107f9a:	8b 40 04             	mov    0x4(%eax),%eax
80107f9d:	83 ec 0c             	sub    $0xc,%esp
80107fa0:	50                   	push   %eax
80107fa1:	e8 02 f8 ff ff       	call   801077a8 <v2p>
80107fa6:	83 c4 10             	add    $0x10,%esp
80107fa9:	83 ec 0c             	sub    $0xc,%esp
80107fac:	50                   	push   %eax
80107fad:	e8 ea f7 ff ff       	call   8010779c <lcr3>
80107fb2:	83 c4 10             	add    $0x10,%esp
  popcli();
80107fb5:	e8 4b d2 ff ff       	call   80105205 <popcli>
}
80107fba:	90                   	nop
80107fbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107fbe:	5b                   	pop    %ebx
80107fbf:	5e                   	pop    %esi
80107fc0:	5d                   	pop    %ebp
80107fc1:	c3                   	ret

80107fc2 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107fc2:	55                   	push   %ebp
80107fc3:	89 e5                	mov    %esp,%ebp
80107fc5:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107fc8:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107fcf:	76 0d                	jbe    80107fde <inituvm+0x1c>
    panic("inituvm: more than a page");
80107fd1:	83 ec 0c             	sub    $0xc,%esp
80107fd4:	68 cb 8b 10 80       	push   $0x80108bcb
80107fd9:	e8 9b 85 ff ff       	call   80100579 <panic>
  mem = kalloc();
80107fde:	e8 96 ac ff ff       	call   80102c79 <kalloc>
80107fe3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107fe6:	83 ec 04             	sub    $0x4,%esp
80107fe9:	68 00 10 00 00       	push   $0x1000
80107fee:	6a 00                	push   $0x0
80107ff0:	ff 75 f4             	push   -0xc(%ebp)
80107ff3:	e8 ce d2 ff ff       	call   801052c6 <memset>
80107ff8:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107ffb:	83 ec 0c             	sub    $0xc,%esp
80107ffe:	ff 75 f4             	push   -0xc(%ebp)
80108001:	e8 a2 f7 ff ff       	call   801077a8 <v2p>
80108006:	83 c4 10             	add    $0x10,%esp
80108009:	83 ec 0c             	sub    $0xc,%esp
8010800c:	6a 06                	push   $0x6
8010800e:	50                   	push   %eax
8010800f:	68 00 10 00 00       	push   $0x1000
80108014:	6a 00                	push   $0x0
80108016:	ff 75 08             	push   0x8(%ebp)
80108019:	e8 b9 fc ff ff       	call   80107cd7 <mappages>
8010801e:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108021:	83 ec 04             	sub    $0x4,%esp
80108024:	ff 75 10             	push   0x10(%ebp)
80108027:	ff 75 0c             	push   0xc(%ebp)
8010802a:	ff 75 f4             	push   -0xc(%ebp)
8010802d:	e8 53 d3 ff ff       	call   80105385 <memmove>
80108032:	83 c4 10             	add    $0x10,%esp
}
80108035:	90                   	nop
80108036:	c9                   	leave
80108037:	c3                   	ret

80108038 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108038:	55                   	push   %ebp
80108039:	89 e5                	mov    %esp,%ebp
8010803b:	53                   	push   %ebx
8010803c:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010803f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108042:	25 ff 0f 00 00       	and    $0xfff,%eax
80108047:	85 c0                	test   %eax,%eax
80108049:	74 0d                	je     80108058 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
8010804b:	83 ec 0c             	sub    $0xc,%esp
8010804e:	68 e8 8b 10 80       	push   $0x80108be8
80108053:	e8 21 85 ff ff       	call   80100579 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108058:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010805f:	e9 95 00 00 00       	jmp    801080f9 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108064:	8b 55 0c             	mov    0xc(%ebp),%edx
80108067:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010806a:	01 d0                	add    %edx,%eax
8010806c:	83 ec 04             	sub    $0x4,%esp
8010806f:	6a 00                	push   $0x0
80108071:	50                   	push   %eax
80108072:	ff 75 08             	push   0x8(%ebp)
80108075:	e8 bd fb ff ff       	call   80107c37 <walkpgdir>
8010807a:	83 c4 10             	add    $0x10,%esp
8010807d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108080:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108084:	75 0d                	jne    80108093 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108086:	83 ec 0c             	sub    $0xc,%esp
80108089:	68 0b 8c 10 80       	push   $0x80108c0b
8010808e:	e8 e6 84 ff ff       	call   80100579 <panic>
    pa = PTE_ADDR(*pte);
80108093:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108096:	8b 00                	mov    (%eax),%eax
80108098:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010809d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801080a0:	8b 45 18             	mov    0x18(%ebp),%eax
801080a3:	2b 45 f4             	sub    -0xc(%ebp),%eax
801080a6:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801080ab:	77 0b                	ja     801080b8 <loaduvm+0x80>
      n = sz - i;
801080ad:	8b 45 18             	mov    0x18(%ebp),%eax
801080b0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801080b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080b6:	eb 07                	jmp    801080bf <loaduvm+0x87>
    else
      n = PGSIZE;
801080b8:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801080bf:	8b 55 14             	mov    0x14(%ebp),%edx
801080c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c5:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801080c8:	83 ec 0c             	sub    $0xc,%esp
801080cb:	ff 75 e8             	push   -0x18(%ebp)
801080ce:	e8 e2 f6 ff ff       	call   801077b5 <p2v>
801080d3:	83 c4 10             	add    $0x10,%esp
801080d6:	ff 75 f0             	push   -0x10(%ebp)
801080d9:	53                   	push   %ebx
801080da:	50                   	push   %eax
801080db:	ff 75 10             	push   0x10(%ebp)
801080de:	e8 0f 9e ff ff       	call   80101ef2 <readi>
801080e3:	83 c4 10             	add    $0x10,%esp
801080e6:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801080e9:	74 07                	je     801080f2 <loaduvm+0xba>
      return -1;
801080eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801080f0:	eb 18                	jmp    8010810a <loaduvm+0xd2>
  for(i = 0; i < sz; i += PGSIZE){
801080f2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801080f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080fc:	3b 45 18             	cmp    0x18(%ebp),%eax
801080ff:	0f 82 5f ff ff ff    	jb     80108064 <loaduvm+0x2c>
  }
  return 0;
80108105:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010810a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010810d:	c9                   	leave
8010810e:	c3                   	ret

8010810f <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010810f:	55                   	push   %ebp
80108110:	89 e5                	mov    %esp,%ebp
80108112:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108115:	8b 45 10             	mov    0x10(%ebp),%eax
80108118:	85 c0                	test   %eax,%eax
8010811a:	79 0a                	jns    80108126 <allocuvm+0x17>
    return 0;
8010811c:	b8 00 00 00 00       	mov    $0x0,%eax
80108121:	e9 ae 00 00 00       	jmp    801081d4 <allocuvm+0xc5>
  if(newsz < oldsz)
80108126:	8b 45 10             	mov    0x10(%ebp),%eax
80108129:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010812c:	73 08                	jae    80108136 <allocuvm+0x27>
    return oldsz;
8010812e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108131:	e9 9e 00 00 00       	jmp    801081d4 <allocuvm+0xc5>

  a = PGROUNDUP(oldsz);
80108136:	8b 45 0c             	mov    0xc(%ebp),%eax
80108139:	05 ff 0f 00 00       	add    $0xfff,%eax
8010813e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108143:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108146:	eb 7d                	jmp    801081c5 <allocuvm+0xb6>
    mem = kalloc();
80108148:	e8 2c ab ff ff       	call   80102c79 <kalloc>
8010814d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108150:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108154:	75 2b                	jne    80108181 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108156:	83 ec 0c             	sub    $0xc,%esp
80108159:	68 29 8c 10 80       	push   $0x80108c29
8010815e:	e8 61 82 ff ff       	call   801003c4 <cprintf>
80108163:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108166:	83 ec 04             	sub    $0x4,%esp
80108169:	ff 75 0c             	push   0xc(%ebp)
8010816c:	ff 75 10             	push   0x10(%ebp)
8010816f:	ff 75 08             	push   0x8(%ebp)
80108172:	e8 5f 00 00 00       	call   801081d6 <deallocuvm>
80108177:	83 c4 10             	add    $0x10,%esp
      return 0;
8010817a:	b8 00 00 00 00       	mov    $0x0,%eax
8010817f:	eb 53                	jmp    801081d4 <allocuvm+0xc5>
    }
    memset(mem, 0, PGSIZE);
80108181:	83 ec 04             	sub    $0x4,%esp
80108184:	68 00 10 00 00       	push   $0x1000
80108189:	6a 00                	push   $0x0
8010818b:	ff 75 f0             	push   -0x10(%ebp)
8010818e:	e8 33 d1 ff ff       	call   801052c6 <memset>
80108193:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108196:	83 ec 0c             	sub    $0xc,%esp
80108199:	ff 75 f0             	push   -0x10(%ebp)
8010819c:	e8 07 f6 ff ff       	call   801077a8 <v2p>
801081a1:	83 c4 10             	add    $0x10,%esp
801081a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801081a7:	83 ec 0c             	sub    $0xc,%esp
801081aa:	6a 06                	push   $0x6
801081ac:	50                   	push   %eax
801081ad:	68 00 10 00 00       	push   $0x1000
801081b2:	52                   	push   %edx
801081b3:	ff 75 08             	push   0x8(%ebp)
801081b6:	e8 1c fb ff ff       	call   80107cd7 <mappages>
801081bb:	83 c4 20             	add    $0x20,%esp
  for(; a < newsz; a += PGSIZE){
801081be:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801081c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c8:	3b 45 10             	cmp    0x10(%ebp),%eax
801081cb:	0f 82 77 ff ff ff    	jb     80108148 <allocuvm+0x39>
  }
  return newsz;
801081d1:	8b 45 10             	mov    0x10(%ebp),%eax
}
801081d4:	c9                   	leave
801081d5:	c3                   	ret

801081d6 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801081d6:	55                   	push   %ebp
801081d7:	89 e5                	mov    %esp,%ebp
801081d9:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801081dc:	8b 45 10             	mov    0x10(%ebp),%eax
801081df:	3b 45 0c             	cmp    0xc(%ebp),%eax
801081e2:	72 08                	jb     801081ec <deallocuvm+0x16>
    return oldsz;
801081e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801081e7:	e9 a5 00 00 00       	jmp    80108291 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
801081ec:	8b 45 10             	mov    0x10(%ebp),%eax
801081ef:	05 ff 0f 00 00       	add    $0xfff,%eax
801081f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801081fc:	e9 81 00 00 00       	jmp    80108282 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108201:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108204:	83 ec 04             	sub    $0x4,%esp
80108207:	6a 00                	push   $0x0
80108209:	50                   	push   %eax
8010820a:	ff 75 08             	push   0x8(%ebp)
8010820d:	e8 25 fa ff ff       	call   80107c37 <walkpgdir>
80108212:	83 c4 10             	add    $0x10,%esp
80108215:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108218:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010821c:	75 09                	jne    80108227 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
8010821e:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108225:	eb 54                	jmp    8010827b <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80108227:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010822a:	8b 00                	mov    (%eax),%eax
8010822c:	83 e0 01             	and    $0x1,%eax
8010822f:	85 c0                	test   %eax,%eax
80108231:	74 48                	je     8010827b <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80108233:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108236:	8b 00                	mov    (%eax),%eax
80108238:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010823d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108240:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108244:	75 0d                	jne    80108253 <deallocuvm+0x7d>
        panic("kfree");
80108246:	83 ec 0c             	sub    $0xc,%esp
80108249:	68 41 8c 10 80       	push   $0x80108c41
8010824e:	e8 26 83 ff ff       	call   80100579 <panic>
      char *v = p2v(pa);
80108253:	83 ec 0c             	sub    $0xc,%esp
80108256:	ff 75 ec             	push   -0x14(%ebp)
80108259:	e8 57 f5 ff ff       	call   801077b5 <p2v>
8010825e:	83 c4 10             	add    $0x10,%esp
80108261:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108264:	83 ec 0c             	sub    $0xc,%esp
80108267:	ff 75 e8             	push   -0x18(%ebp)
8010826a:	e8 6d a9 ff ff       	call   80102bdc <kfree>
8010826f:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108272:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108275:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010827b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108282:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108285:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108288:	0f 82 73 ff ff ff    	jb     80108201 <deallocuvm+0x2b>
    }
  }
  return newsz;
8010828e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108291:	c9                   	leave
80108292:	c3                   	ret

80108293 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108293:	55                   	push   %ebp
80108294:	89 e5                	mov    %esp,%ebp
80108296:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108299:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010829d:	75 0d                	jne    801082ac <freevm+0x19>
    panic("freevm: no pgdir");
8010829f:	83 ec 0c             	sub    $0xc,%esp
801082a2:	68 47 8c 10 80       	push   $0x80108c47
801082a7:	e8 cd 82 ff ff       	call   80100579 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801082ac:	83 ec 04             	sub    $0x4,%esp
801082af:	6a 00                	push   $0x0
801082b1:	68 00 00 00 80       	push   $0x80000000
801082b6:	ff 75 08             	push   0x8(%ebp)
801082b9:	e8 18 ff ff ff       	call   801081d6 <deallocuvm>
801082be:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801082c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082c8:	eb 4f                	jmp    80108319 <freevm+0x86>
    if(pgdir[i] & PTE_P){
801082ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801082d4:	8b 45 08             	mov    0x8(%ebp),%eax
801082d7:	01 d0                	add    %edx,%eax
801082d9:	8b 00                	mov    (%eax),%eax
801082db:	83 e0 01             	and    $0x1,%eax
801082de:	85 c0                	test   %eax,%eax
801082e0:	74 33                	je     80108315 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801082e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801082ec:	8b 45 08             	mov    0x8(%ebp),%eax
801082ef:	01 d0                	add    %edx,%eax
801082f1:	8b 00                	mov    (%eax),%eax
801082f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082f8:	83 ec 0c             	sub    $0xc,%esp
801082fb:	50                   	push   %eax
801082fc:	e8 b4 f4 ff ff       	call   801077b5 <p2v>
80108301:	83 c4 10             	add    $0x10,%esp
80108304:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108307:	83 ec 0c             	sub    $0xc,%esp
8010830a:	ff 75 f0             	push   -0x10(%ebp)
8010830d:	e8 ca a8 ff ff       	call   80102bdc <kfree>
80108312:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108315:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108319:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108320:	76 a8                	jbe    801082ca <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80108322:	83 ec 0c             	sub    $0xc,%esp
80108325:	ff 75 08             	push   0x8(%ebp)
80108328:	e8 af a8 ff ff       	call   80102bdc <kfree>
8010832d:	83 c4 10             	add    $0x10,%esp
}
80108330:	90                   	nop
80108331:	c9                   	leave
80108332:	c3                   	ret

80108333 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108333:	55                   	push   %ebp
80108334:	89 e5                	mov    %esp,%ebp
80108336:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108339:	83 ec 04             	sub    $0x4,%esp
8010833c:	6a 00                	push   $0x0
8010833e:	ff 75 0c             	push   0xc(%ebp)
80108341:	ff 75 08             	push   0x8(%ebp)
80108344:	e8 ee f8 ff ff       	call   80107c37 <walkpgdir>
80108349:	83 c4 10             	add    $0x10,%esp
8010834c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010834f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108353:	75 0d                	jne    80108362 <clearpteu+0x2f>
    panic("clearpteu");
80108355:	83 ec 0c             	sub    $0xc,%esp
80108358:	68 58 8c 10 80       	push   $0x80108c58
8010835d:	e8 17 82 ff ff       	call   80100579 <panic>
  *pte &= ~PTE_U;
80108362:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108365:	8b 00                	mov    (%eax),%eax
80108367:	83 e0 fb             	and    $0xfffffffb,%eax
8010836a:	89 c2                	mov    %eax,%edx
8010836c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010836f:	89 10                	mov    %edx,(%eax)
}
80108371:	90                   	nop
80108372:	c9                   	leave
80108373:	c3                   	ret

80108374 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108374:	55                   	push   %ebp
80108375:	89 e5                	mov    %esp,%ebp
80108377:	53                   	push   %ebx
80108378:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010837b:	e8 e7 f9 ff ff       	call   80107d67 <setupkvm>
80108380:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108383:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108387:	75 0a                	jne    80108393 <copyuvm+0x1f>
    return 0;
80108389:	b8 00 00 00 00       	mov    $0x0,%eax
8010838e:	e9 f6 00 00 00       	jmp    80108489 <copyuvm+0x115>
  for(i = 0; i < sz; i += PGSIZE){
80108393:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010839a:	e9 c2 00 00 00       	jmp    80108461 <copyuvm+0xed>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010839f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083a2:	83 ec 04             	sub    $0x4,%esp
801083a5:	6a 00                	push   $0x0
801083a7:	50                   	push   %eax
801083a8:	ff 75 08             	push   0x8(%ebp)
801083ab:	e8 87 f8 ff ff       	call   80107c37 <walkpgdir>
801083b0:	83 c4 10             	add    $0x10,%esp
801083b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801083b6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083ba:	75 0d                	jne    801083c9 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
801083bc:	83 ec 0c             	sub    $0xc,%esp
801083bf:	68 62 8c 10 80       	push   $0x80108c62
801083c4:	e8 b0 81 ff ff       	call   80100579 <panic>
    if(!(*pte & PTE_P))
801083c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083cc:	8b 00                	mov    (%eax),%eax
801083ce:	83 e0 01             	and    $0x1,%eax
801083d1:	85 c0                	test   %eax,%eax
801083d3:	75 0d                	jne    801083e2 <copyuvm+0x6e>
      panic("copyuvm: page not present");
801083d5:	83 ec 0c             	sub    $0xc,%esp
801083d8:	68 7c 8c 10 80       	push   $0x80108c7c
801083dd:	e8 97 81 ff ff       	call   80100579 <panic>
    pa = PTE_ADDR(*pte);
801083e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083e5:	8b 00                	mov    (%eax),%eax
801083e7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801083ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083f2:	8b 00                	mov    (%eax),%eax
801083f4:	25 ff 0f 00 00       	and    $0xfff,%eax
801083f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801083fc:	e8 78 a8 ff ff       	call   80102c79 <kalloc>
80108401:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108404:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108408:	74 68                	je     80108472 <copyuvm+0xfe>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010840a:	83 ec 0c             	sub    $0xc,%esp
8010840d:	ff 75 e8             	push   -0x18(%ebp)
80108410:	e8 a0 f3 ff ff       	call   801077b5 <p2v>
80108415:	83 c4 10             	add    $0x10,%esp
80108418:	83 ec 04             	sub    $0x4,%esp
8010841b:	68 00 10 00 00       	push   $0x1000
80108420:	50                   	push   %eax
80108421:	ff 75 e0             	push   -0x20(%ebp)
80108424:	e8 5c cf ff ff       	call   80105385 <memmove>
80108429:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010842c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010842f:	83 ec 0c             	sub    $0xc,%esp
80108432:	ff 75 e0             	push   -0x20(%ebp)
80108435:	e8 6e f3 ff ff       	call   801077a8 <v2p>
8010843a:	83 c4 10             	add    $0x10,%esp
8010843d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108440:	83 ec 0c             	sub    $0xc,%esp
80108443:	53                   	push   %ebx
80108444:	50                   	push   %eax
80108445:	68 00 10 00 00       	push   $0x1000
8010844a:	52                   	push   %edx
8010844b:	ff 75 f0             	push   -0x10(%ebp)
8010844e:	e8 84 f8 ff ff       	call   80107cd7 <mappages>
80108453:	83 c4 20             	add    $0x20,%esp
80108456:	85 c0                	test   %eax,%eax
80108458:	78 1b                	js     80108475 <copyuvm+0x101>
  for(i = 0; i < sz; i += PGSIZE){
8010845a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108464:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108467:	0f 82 32 ff ff ff    	jb     8010839f <copyuvm+0x2b>
      goto bad;
  }
  return d;
8010846d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108470:	eb 17                	jmp    80108489 <copyuvm+0x115>
      goto bad;
80108472:	90                   	nop
80108473:	eb 01                	jmp    80108476 <copyuvm+0x102>
      goto bad;
80108475:	90                   	nop

bad:
  freevm(d);
80108476:	83 ec 0c             	sub    $0xc,%esp
80108479:	ff 75 f0             	push   -0x10(%ebp)
8010847c:	e8 12 fe ff ff       	call   80108293 <freevm>
80108481:	83 c4 10             	add    $0x10,%esp
  return 0;
80108484:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108489:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010848c:	c9                   	leave
8010848d:	c3                   	ret

8010848e <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010848e:	55                   	push   %ebp
8010848f:	89 e5                	mov    %esp,%ebp
80108491:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108494:	83 ec 04             	sub    $0x4,%esp
80108497:	6a 00                	push   $0x0
80108499:	ff 75 0c             	push   0xc(%ebp)
8010849c:	ff 75 08             	push   0x8(%ebp)
8010849f:	e8 93 f7 ff ff       	call   80107c37 <walkpgdir>
801084a4:	83 c4 10             	add    $0x10,%esp
801084a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801084aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ad:	8b 00                	mov    (%eax),%eax
801084af:	83 e0 01             	and    $0x1,%eax
801084b2:	85 c0                	test   %eax,%eax
801084b4:	75 07                	jne    801084bd <uva2ka+0x2f>
    return 0;
801084b6:	b8 00 00 00 00       	mov    $0x0,%eax
801084bb:	eb 2a                	jmp    801084e7 <uva2ka+0x59>
  if((*pte & PTE_U) == 0)
801084bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c0:	8b 00                	mov    (%eax),%eax
801084c2:	83 e0 04             	and    $0x4,%eax
801084c5:	85 c0                	test   %eax,%eax
801084c7:	75 07                	jne    801084d0 <uva2ka+0x42>
    return 0;
801084c9:	b8 00 00 00 00       	mov    $0x0,%eax
801084ce:	eb 17                	jmp    801084e7 <uva2ka+0x59>
  return (char*)p2v(PTE_ADDR(*pte));
801084d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d3:	8b 00                	mov    (%eax),%eax
801084d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084da:	83 ec 0c             	sub    $0xc,%esp
801084dd:	50                   	push   %eax
801084de:	e8 d2 f2 ff ff       	call   801077b5 <p2v>
801084e3:	83 c4 10             	add    $0x10,%esp
801084e6:	90                   	nop
}
801084e7:	c9                   	leave
801084e8:	c3                   	ret

801084e9 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801084e9:	55                   	push   %ebp
801084ea:	89 e5                	mov    %esp,%ebp
801084ec:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801084ef:	8b 45 10             	mov    0x10(%ebp),%eax
801084f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801084f5:	eb 7f                	jmp    80108576 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801084f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801084fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108502:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108505:	83 ec 08             	sub    $0x8,%esp
80108508:	50                   	push   %eax
80108509:	ff 75 08             	push   0x8(%ebp)
8010850c:	e8 7d ff ff ff       	call   8010848e <uva2ka>
80108511:	83 c4 10             	add    $0x10,%esp
80108514:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108517:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010851b:	75 07                	jne    80108524 <copyout+0x3b>
      return -1;
8010851d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108522:	eb 61                	jmp    80108585 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108524:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108527:	2b 45 0c             	sub    0xc(%ebp),%eax
8010852a:	05 00 10 00 00       	add    $0x1000,%eax
8010852f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108532:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108535:	39 45 14             	cmp    %eax,0x14(%ebp)
80108538:	73 06                	jae    80108540 <copyout+0x57>
      n = len;
8010853a:	8b 45 14             	mov    0x14(%ebp),%eax
8010853d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108540:	8b 45 0c             	mov    0xc(%ebp),%eax
80108543:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108546:	89 c2                	mov    %eax,%edx
80108548:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010854b:	01 d0                	add    %edx,%eax
8010854d:	83 ec 04             	sub    $0x4,%esp
80108550:	ff 75 f0             	push   -0x10(%ebp)
80108553:	ff 75 f4             	push   -0xc(%ebp)
80108556:	50                   	push   %eax
80108557:	e8 29 ce ff ff       	call   80105385 <memmove>
8010855c:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010855f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108562:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108565:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108568:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010856b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010856e:	05 00 10 00 00       	add    $0x1000,%eax
80108573:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108576:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010857a:	0f 85 77 ff ff ff    	jne    801084f7 <copyout+0xe>
  }
  return 0;
80108580:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108585:	c9                   	leave
80108586:	c3                   	ret
