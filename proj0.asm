
_proj0:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	83 ec 10             	sub    $0x10,%esp
  12:	89 cb                	mov    %ecx,%ebx
  printf(1, "CSE3320 proj0 printing in user space: ");
  14:	83 ec 08             	sub    $0x8,%esp
  17:	68 14 08 00 00       	push   $0x814
  1c:	6a 01                	push   $0x1
  1e:	e8 39 04 00 00       	call   45c <printf>
  23:	83 c4 10             	add    $0x10,%esp
  for (int i = 1; i < argc; i++) {
  26:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  2d:	eb 44                	jmp    73 <main+0x73>
    printf(1, "%s", argv[i]);
  2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  32:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  39:	8b 43 04             	mov    0x4(%ebx),%eax
  3c:	01 d0                	add    %edx,%eax
  3e:	8b 00                	mov    (%eax),%eax
  40:	83 ec 04             	sub    $0x4,%esp
  43:	50                   	push   %eax
  44:	68 3b 08 00 00       	push   $0x83b
  49:	6a 01                	push   $0x1
  4b:	e8 0c 04 00 00       	call   45c <printf>
  50:	83 c4 10             	add    $0x10,%esp
    if (i + 1 < argc) printf(1, " ");
  53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  56:	83 c0 01             	add    $0x1,%eax
  59:	39 03                	cmp    %eax,(%ebx)
  5b:	7e 12                	jle    6f <main+0x6f>
  5d:	83 ec 08             	sub    $0x8,%esp
  60:	68 3e 08 00 00       	push   $0x83e
  65:	6a 01                	push   $0x1
  67:	e8 f0 03 00 00       	call   45c <printf>
  6c:	83 c4 10             	add    $0x10,%esp
  for (int i = 1; i < argc; i++) {
  6f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  76:	3b 03                	cmp    (%ebx),%eax
  78:	7c b5                	jl     2f <main+0x2f>
  }
  printf(1, "\n");
  7a:	83 ec 08             	sub    $0x8,%esp
  7d:	68 40 08 00 00       	push   $0x840
  82:	6a 01                	push   $0x1
  84:	e8 d3 03 00 00       	call   45c <printf>
  89:	83 c4 10             	add    $0x10,%esp
  exit();
  8c:	e8 57 02 00 00       	call   2e8 <exit>

00000091 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  91:	55                   	push   %ebp
  92:	89 e5                	mov    %esp,%ebp
  94:	57                   	push   %edi
  95:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  99:	8b 55 10             	mov    0x10(%ebp),%edx
  9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  9f:	89 cb                	mov    %ecx,%ebx
  a1:	89 df                	mov    %ebx,%edi
  a3:	89 d1                	mov    %edx,%ecx
  a5:	fc                   	cld
  a6:	f3 aa                	rep stos %al,%es:(%edi)
  a8:	89 ca                	mov    %ecx,%edx
  aa:	89 fb                	mov    %edi,%ebx
  ac:	89 5d 08             	mov    %ebx,0x8(%ebp)
  af:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  b2:	90                   	nop
  b3:	5b                   	pop    %ebx
  b4:	5f                   	pop    %edi
  b5:	5d                   	pop    %ebp
  b6:	c3                   	ret

000000b7 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  b7:	55                   	push   %ebp
  b8:	89 e5                	mov    %esp,%ebp
  ba:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  bd:	8b 45 08             	mov    0x8(%ebp),%eax
  c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  c3:	90                   	nop
  c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  c7:	8d 42 01             	lea    0x1(%edx),%eax
  ca:	89 45 0c             	mov    %eax,0xc(%ebp)
  cd:	8b 45 08             	mov    0x8(%ebp),%eax
  d0:	8d 48 01             	lea    0x1(%eax),%ecx
  d3:	89 4d 08             	mov    %ecx,0x8(%ebp)
  d6:	0f b6 12             	movzbl (%edx),%edx
  d9:	88 10                	mov    %dl,(%eax)
  db:	0f b6 00             	movzbl (%eax),%eax
  de:	84 c0                	test   %al,%al
  e0:	75 e2                	jne    c4 <strcpy+0xd>
    ;
  return os;
  e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  e5:	c9                   	leave
  e6:	c3                   	ret

000000e7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e7:	55                   	push   %ebp
  e8:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  ea:	eb 08                	jmp    f4 <strcmp+0xd>
    p++, q++;
  ec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  f0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  f4:	8b 45 08             	mov    0x8(%ebp),%eax
  f7:	0f b6 00             	movzbl (%eax),%eax
  fa:	84 c0                	test   %al,%al
  fc:	74 10                	je     10e <strcmp+0x27>
  fe:	8b 45 08             	mov    0x8(%ebp),%eax
 101:	0f b6 10             	movzbl (%eax),%edx
 104:	8b 45 0c             	mov    0xc(%ebp),%eax
 107:	0f b6 00             	movzbl (%eax),%eax
 10a:	38 c2                	cmp    %al,%dl
 10c:	74 de                	je     ec <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 10e:	8b 45 08             	mov    0x8(%ebp),%eax
 111:	0f b6 00             	movzbl (%eax),%eax
 114:	0f b6 d0             	movzbl %al,%edx
 117:	8b 45 0c             	mov    0xc(%ebp),%eax
 11a:	0f b6 00             	movzbl (%eax),%eax
 11d:	0f b6 c0             	movzbl %al,%eax
 120:	29 c2                	sub    %eax,%edx
 122:	89 d0                	mov    %edx,%eax
}
 124:	5d                   	pop    %ebp
 125:	c3                   	ret

00000126 <strlen>:

uint
strlen(char *s)
{
 126:	55                   	push   %ebp
 127:	89 e5                	mov    %esp,%ebp
 129:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 12c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 133:	eb 04                	jmp    139 <strlen+0x13>
 135:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 139:	8b 55 fc             	mov    -0x4(%ebp),%edx
 13c:	8b 45 08             	mov    0x8(%ebp),%eax
 13f:	01 d0                	add    %edx,%eax
 141:	0f b6 00             	movzbl (%eax),%eax
 144:	84 c0                	test   %al,%al
 146:	75 ed                	jne    135 <strlen+0xf>
    ;
  return n;
 148:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 14b:	c9                   	leave
 14c:	c3                   	ret

0000014d <memset>:

void*
memset(void *dst, int c, uint n)
{
 14d:	55                   	push   %ebp
 14e:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 150:	8b 45 10             	mov    0x10(%ebp),%eax
 153:	50                   	push   %eax
 154:	ff 75 0c             	push   0xc(%ebp)
 157:	ff 75 08             	push   0x8(%ebp)
 15a:	e8 32 ff ff ff       	call   91 <stosb>
 15f:	83 c4 0c             	add    $0xc,%esp
  return dst;
 162:	8b 45 08             	mov    0x8(%ebp),%eax
}
 165:	c9                   	leave
 166:	c3                   	ret

00000167 <strchr>:

char*
strchr(const char *s, char c)
{
 167:	55                   	push   %ebp
 168:	89 e5                	mov    %esp,%ebp
 16a:	83 ec 04             	sub    $0x4,%esp
 16d:	8b 45 0c             	mov    0xc(%ebp),%eax
 170:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 173:	eb 14                	jmp    189 <strchr+0x22>
    if(*s == c)
 175:	8b 45 08             	mov    0x8(%ebp),%eax
 178:	0f b6 00             	movzbl (%eax),%eax
 17b:	38 45 fc             	cmp    %al,-0x4(%ebp)
 17e:	75 05                	jne    185 <strchr+0x1e>
      return (char*)s;
 180:	8b 45 08             	mov    0x8(%ebp),%eax
 183:	eb 13                	jmp    198 <strchr+0x31>
  for(; *s; s++)
 185:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 189:	8b 45 08             	mov    0x8(%ebp),%eax
 18c:	0f b6 00             	movzbl (%eax),%eax
 18f:	84 c0                	test   %al,%al
 191:	75 e2                	jne    175 <strchr+0xe>
  return 0;
 193:	b8 00 00 00 00       	mov    $0x0,%eax
}
 198:	c9                   	leave
 199:	c3                   	ret

0000019a <gets>:

char*
gets(char *buf, int max)
{
 19a:	55                   	push   %ebp
 19b:	89 e5                	mov    %esp,%ebp
 19d:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1a7:	eb 42                	jmp    1eb <gets+0x51>
    cc = read(0, &c, 1);
 1a9:	83 ec 04             	sub    $0x4,%esp
 1ac:	6a 01                	push   $0x1
 1ae:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1b1:	50                   	push   %eax
 1b2:	6a 00                	push   $0x0
 1b4:	e8 47 01 00 00       	call   300 <read>
 1b9:	83 c4 10             	add    $0x10,%esp
 1bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1c3:	7e 33                	jle    1f8 <gets+0x5e>
      break;
    buf[i++] = c;
 1c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c8:	8d 50 01             	lea    0x1(%eax),%edx
 1cb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1ce:	89 c2                	mov    %eax,%edx
 1d0:	8b 45 08             	mov    0x8(%ebp),%eax
 1d3:	01 c2                	add    %eax,%edx
 1d5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d9:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1db:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1df:	3c 0a                	cmp    $0xa,%al
 1e1:	74 16                	je     1f9 <gets+0x5f>
 1e3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e7:	3c 0d                	cmp    $0xd,%al
 1e9:	74 0e                	je     1f9 <gets+0x5f>
  for(i=0; i+1 < max; ){
 1eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ee:	83 c0 01             	add    $0x1,%eax
 1f1:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1f4:	7f b3                	jg     1a9 <gets+0xf>
 1f6:	eb 01                	jmp    1f9 <gets+0x5f>
      break;
 1f8:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1fc:	8b 45 08             	mov    0x8(%ebp),%eax
 1ff:	01 d0                	add    %edx,%eax
 201:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 204:	8b 45 08             	mov    0x8(%ebp),%eax
}
 207:	c9                   	leave
 208:	c3                   	ret

00000209 <stat>:

int
stat(char *n, struct stat *st)
{
 209:	55                   	push   %ebp
 20a:	89 e5                	mov    %esp,%ebp
 20c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20f:	83 ec 08             	sub    $0x8,%esp
 212:	6a 00                	push   $0x0
 214:	ff 75 08             	push   0x8(%ebp)
 217:	e8 0c 01 00 00       	call   328 <open>
 21c:	83 c4 10             	add    $0x10,%esp
 21f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 222:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 226:	79 07                	jns    22f <stat+0x26>
    return -1;
 228:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 22d:	eb 25                	jmp    254 <stat+0x4b>
  r = fstat(fd, st);
 22f:	83 ec 08             	sub    $0x8,%esp
 232:	ff 75 0c             	push   0xc(%ebp)
 235:	ff 75 f4             	push   -0xc(%ebp)
 238:	e8 03 01 00 00       	call   340 <fstat>
 23d:	83 c4 10             	add    $0x10,%esp
 240:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 243:	83 ec 0c             	sub    $0xc,%esp
 246:	ff 75 f4             	push   -0xc(%ebp)
 249:	e8 c2 00 00 00       	call   310 <close>
 24e:	83 c4 10             	add    $0x10,%esp
  return r;
 251:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 254:	c9                   	leave
 255:	c3                   	ret

00000256 <atoi>:

int
atoi(const char *s)
{
 256:	55                   	push   %ebp
 257:	89 e5                	mov    %esp,%ebp
 259:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 25c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 263:	eb 25                	jmp    28a <atoi+0x34>
    n = n*10 + *s++ - '0';
 265:	8b 55 fc             	mov    -0x4(%ebp),%edx
 268:	89 d0                	mov    %edx,%eax
 26a:	c1 e0 02             	shl    $0x2,%eax
 26d:	01 d0                	add    %edx,%eax
 26f:	01 c0                	add    %eax,%eax
 271:	89 c1                	mov    %eax,%ecx
 273:	8b 45 08             	mov    0x8(%ebp),%eax
 276:	8d 50 01             	lea    0x1(%eax),%edx
 279:	89 55 08             	mov    %edx,0x8(%ebp)
 27c:	0f b6 00             	movzbl (%eax),%eax
 27f:	0f be c0             	movsbl %al,%eax
 282:	01 c8                	add    %ecx,%eax
 284:	83 e8 30             	sub    $0x30,%eax
 287:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 28a:	8b 45 08             	mov    0x8(%ebp),%eax
 28d:	0f b6 00             	movzbl (%eax),%eax
 290:	3c 2f                	cmp    $0x2f,%al
 292:	7e 0a                	jle    29e <atoi+0x48>
 294:	8b 45 08             	mov    0x8(%ebp),%eax
 297:	0f b6 00             	movzbl (%eax),%eax
 29a:	3c 39                	cmp    $0x39,%al
 29c:	7e c7                	jle    265 <atoi+0xf>
  return n;
 29e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2a1:	c9                   	leave
 2a2:	c3                   	ret

000002a3 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2a3:	55                   	push   %ebp
 2a4:	89 e5                	mov    %esp,%ebp
 2a6:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2a9:	8b 45 08             	mov    0x8(%ebp),%eax
 2ac:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2af:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2b5:	eb 17                	jmp    2ce <memmove+0x2b>
    *dst++ = *src++;
 2b7:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2ba:	8d 42 01             	lea    0x1(%edx),%eax
 2bd:	89 45 f8             	mov    %eax,-0x8(%ebp)
 2c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2c3:	8d 48 01             	lea    0x1(%eax),%ecx
 2c6:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 2c9:	0f b6 12             	movzbl (%edx),%edx
 2cc:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 2ce:	8b 45 10             	mov    0x10(%ebp),%eax
 2d1:	8d 50 ff             	lea    -0x1(%eax),%edx
 2d4:	89 55 10             	mov    %edx,0x10(%ebp)
 2d7:	85 c0                	test   %eax,%eax
 2d9:	7f dc                	jg     2b7 <memmove+0x14>
  return vdst;
 2db:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2de:	c9                   	leave
 2df:	c3                   	ret

000002e0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2e0:	b8 01 00 00 00       	mov    $0x1,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret

000002e8 <exit>:
SYSCALL(exit)
 2e8:	b8 02 00 00 00       	mov    $0x2,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret

000002f0 <wait>:
SYSCALL(wait)
 2f0:	b8 03 00 00 00       	mov    $0x3,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret

000002f8 <pipe>:
SYSCALL(pipe)
 2f8:	b8 04 00 00 00       	mov    $0x4,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret

00000300 <read>:
SYSCALL(read)
 300:	b8 05 00 00 00       	mov    $0x5,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret

00000308 <write>:
SYSCALL(write)
 308:	b8 10 00 00 00       	mov    $0x10,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret

00000310 <close>:
SYSCALL(close)
 310:	b8 15 00 00 00       	mov    $0x15,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret

00000318 <kill>:
SYSCALL(kill)
 318:	b8 06 00 00 00       	mov    $0x6,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret

00000320 <exec>:
SYSCALL(exec)
 320:	b8 07 00 00 00       	mov    $0x7,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret

00000328 <open>:
SYSCALL(open)
 328:	b8 0f 00 00 00       	mov    $0xf,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret

00000330 <mknod>:
SYSCALL(mknod)
 330:	b8 11 00 00 00       	mov    $0x11,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret

00000338 <unlink>:
SYSCALL(unlink)
 338:	b8 12 00 00 00       	mov    $0x12,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret

00000340 <fstat>:
SYSCALL(fstat)
 340:	b8 08 00 00 00       	mov    $0x8,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret

00000348 <link>:
SYSCALL(link)
 348:	b8 13 00 00 00       	mov    $0x13,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret

00000350 <mkdir>:
SYSCALL(mkdir)
 350:	b8 14 00 00 00       	mov    $0x14,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret

00000358 <chdir>:
SYSCALL(chdir)
 358:	b8 09 00 00 00       	mov    $0x9,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret

00000360 <dup>:
SYSCALL(dup)
 360:	b8 0a 00 00 00       	mov    $0xa,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret

00000368 <getpid>:
SYSCALL(getpid)
 368:	b8 0b 00 00 00       	mov    $0xb,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret

00000370 <sbrk>:
SYSCALL(sbrk)
 370:	b8 0c 00 00 00       	mov    $0xc,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret

00000378 <sleep>:
SYSCALL(sleep)
 378:	b8 0d 00 00 00       	mov    $0xd,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret

00000380 <uptime>:
SYSCALL(uptime)
 380:	b8 0e 00 00 00       	mov    $0xe,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret

00000388 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 388:	55                   	push   %ebp
 389:	89 e5                	mov    %esp,%ebp
 38b:	83 ec 18             	sub    $0x18,%esp
 38e:	8b 45 0c             	mov    0xc(%ebp),%eax
 391:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 394:	83 ec 04             	sub    $0x4,%esp
 397:	6a 01                	push   $0x1
 399:	8d 45 f4             	lea    -0xc(%ebp),%eax
 39c:	50                   	push   %eax
 39d:	ff 75 08             	push   0x8(%ebp)
 3a0:	e8 63 ff ff ff       	call   308 <write>
 3a5:	83 c4 10             	add    $0x10,%esp
}
 3a8:	90                   	nop
 3a9:	c9                   	leave
 3aa:	c3                   	ret

000003ab <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3ab:	55                   	push   %ebp
 3ac:	89 e5                	mov    %esp,%ebp
 3ae:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3b1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3b8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3bc:	74 17                	je     3d5 <printint+0x2a>
 3be:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3c2:	79 11                	jns    3d5 <printint+0x2a>
    neg = 1;
 3c4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3cb:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ce:	f7 d8                	neg    %eax
 3d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3d3:	eb 06                	jmp    3db <printint+0x30>
  } else {
    x = xx;
 3d5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3e8:	ba 00 00 00 00       	mov    $0x0,%edx
 3ed:	f7 f1                	div    %ecx
 3ef:	89 d1                	mov    %edx,%ecx
 3f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3f4:	8d 50 01             	lea    0x1(%eax),%edx
 3f7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3fa:	0f b6 91 94 0a 00 00 	movzbl 0xa94(%ecx),%edx
 401:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 405:	8b 4d 10             	mov    0x10(%ebp),%ecx
 408:	8b 45 ec             	mov    -0x14(%ebp),%eax
 40b:	ba 00 00 00 00       	mov    $0x0,%edx
 410:	f7 f1                	div    %ecx
 412:	89 45 ec             	mov    %eax,-0x14(%ebp)
 415:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 419:	75 c7                	jne    3e2 <printint+0x37>
  if(neg)
 41b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 41f:	74 2d                	je     44e <printint+0xa3>
    buf[i++] = '-';
 421:	8b 45 f4             	mov    -0xc(%ebp),%eax
 424:	8d 50 01             	lea    0x1(%eax),%edx
 427:	89 55 f4             	mov    %edx,-0xc(%ebp)
 42a:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 42f:	eb 1d                	jmp    44e <printint+0xa3>
    putc(fd, buf[i]);
 431:	8d 55 dc             	lea    -0x24(%ebp),%edx
 434:	8b 45 f4             	mov    -0xc(%ebp),%eax
 437:	01 d0                	add    %edx,%eax
 439:	0f b6 00             	movzbl (%eax),%eax
 43c:	0f be c0             	movsbl %al,%eax
 43f:	83 ec 08             	sub    $0x8,%esp
 442:	50                   	push   %eax
 443:	ff 75 08             	push   0x8(%ebp)
 446:	e8 3d ff ff ff       	call   388 <putc>
 44b:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 44e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 452:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 456:	79 d9                	jns    431 <printint+0x86>
}
 458:	90                   	nop
 459:	90                   	nop
 45a:	c9                   	leave
 45b:	c3                   	ret

0000045c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 45c:	55                   	push   %ebp
 45d:	89 e5                	mov    %esp,%ebp
 45f:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 462:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 469:	8d 45 0c             	lea    0xc(%ebp),%eax
 46c:	83 c0 04             	add    $0x4,%eax
 46f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 472:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 479:	e9 59 01 00 00       	jmp    5d7 <printf+0x17b>
    c = fmt[i] & 0xff;
 47e:	8b 55 0c             	mov    0xc(%ebp),%edx
 481:	8b 45 f0             	mov    -0x10(%ebp),%eax
 484:	01 d0                	add    %edx,%eax
 486:	0f b6 00             	movzbl (%eax),%eax
 489:	0f be c0             	movsbl %al,%eax
 48c:	25 ff 00 00 00       	and    $0xff,%eax
 491:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 494:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 498:	75 2c                	jne    4c6 <printf+0x6a>
      if(c == '%'){
 49a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 49e:	75 0c                	jne    4ac <printf+0x50>
        state = '%';
 4a0:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4a7:	e9 27 01 00 00       	jmp    5d3 <printf+0x177>
      } else {
        putc(fd, c);
 4ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4af:	0f be c0             	movsbl %al,%eax
 4b2:	83 ec 08             	sub    $0x8,%esp
 4b5:	50                   	push   %eax
 4b6:	ff 75 08             	push   0x8(%ebp)
 4b9:	e8 ca fe ff ff       	call   388 <putc>
 4be:	83 c4 10             	add    $0x10,%esp
 4c1:	e9 0d 01 00 00       	jmp    5d3 <printf+0x177>
      }
    } else if(state == '%'){
 4c6:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4ca:	0f 85 03 01 00 00    	jne    5d3 <printf+0x177>
      if(c == 'd'){
 4d0:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4d4:	75 1e                	jne    4f4 <printf+0x98>
        printint(fd, *ap, 10, 1);
 4d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4d9:	8b 00                	mov    (%eax),%eax
 4db:	6a 01                	push   $0x1
 4dd:	6a 0a                	push   $0xa
 4df:	50                   	push   %eax
 4e0:	ff 75 08             	push   0x8(%ebp)
 4e3:	e8 c3 fe ff ff       	call   3ab <printint>
 4e8:	83 c4 10             	add    $0x10,%esp
        ap++;
 4eb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4ef:	e9 d8 00 00 00       	jmp    5cc <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 4f4:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4f8:	74 06                	je     500 <printf+0xa4>
 4fa:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4fe:	75 1e                	jne    51e <printf+0xc2>
        printint(fd, *ap, 16, 0);
 500:	8b 45 e8             	mov    -0x18(%ebp),%eax
 503:	8b 00                	mov    (%eax),%eax
 505:	6a 00                	push   $0x0
 507:	6a 10                	push   $0x10
 509:	50                   	push   %eax
 50a:	ff 75 08             	push   0x8(%ebp)
 50d:	e8 99 fe ff ff       	call   3ab <printint>
 512:	83 c4 10             	add    $0x10,%esp
        ap++;
 515:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 519:	e9 ae 00 00 00       	jmp    5cc <printf+0x170>
      } else if(c == 's'){
 51e:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 522:	75 43                	jne    567 <printf+0x10b>
        s = (char*)*ap;
 524:	8b 45 e8             	mov    -0x18(%ebp),%eax
 527:	8b 00                	mov    (%eax),%eax
 529:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 52c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 530:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 534:	75 25                	jne    55b <printf+0xff>
          s = "(null)";
 536:	c7 45 f4 42 08 00 00 	movl   $0x842,-0xc(%ebp)
        while(*s != 0){
 53d:	eb 1c                	jmp    55b <printf+0xff>
          putc(fd, *s);
 53f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 542:	0f b6 00             	movzbl (%eax),%eax
 545:	0f be c0             	movsbl %al,%eax
 548:	83 ec 08             	sub    $0x8,%esp
 54b:	50                   	push   %eax
 54c:	ff 75 08             	push   0x8(%ebp)
 54f:	e8 34 fe ff ff       	call   388 <putc>
 554:	83 c4 10             	add    $0x10,%esp
          s++;
 557:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 55b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 55e:	0f b6 00             	movzbl (%eax),%eax
 561:	84 c0                	test   %al,%al
 563:	75 da                	jne    53f <printf+0xe3>
 565:	eb 65                	jmp    5cc <printf+0x170>
        }
      } else if(c == 'c'){
 567:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 56b:	75 1d                	jne    58a <printf+0x12e>
        putc(fd, *ap);
 56d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 570:	8b 00                	mov    (%eax),%eax
 572:	0f be c0             	movsbl %al,%eax
 575:	83 ec 08             	sub    $0x8,%esp
 578:	50                   	push   %eax
 579:	ff 75 08             	push   0x8(%ebp)
 57c:	e8 07 fe ff ff       	call   388 <putc>
 581:	83 c4 10             	add    $0x10,%esp
        ap++;
 584:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 588:	eb 42                	jmp    5cc <printf+0x170>
      } else if(c == '%'){
 58a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 58e:	75 17                	jne    5a7 <printf+0x14b>
        putc(fd, c);
 590:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 593:	0f be c0             	movsbl %al,%eax
 596:	83 ec 08             	sub    $0x8,%esp
 599:	50                   	push   %eax
 59a:	ff 75 08             	push   0x8(%ebp)
 59d:	e8 e6 fd ff ff       	call   388 <putc>
 5a2:	83 c4 10             	add    $0x10,%esp
 5a5:	eb 25                	jmp    5cc <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5a7:	83 ec 08             	sub    $0x8,%esp
 5aa:	6a 25                	push   $0x25
 5ac:	ff 75 08             	push   0x8(%ebp)
 5af:	e8 d4 fd ff ff       	call   388 <putc>
 5b4:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5ba:	0f be c0             	movsbl %al,%eax
 5bd:	83 ec 08             	sub    $0x8,%esp
 5c0:	50                   	push   %eax
 5c1:	ff 75 08             	push   0x8(%ebp)
 5c4:	e8 bf fd ff ff       	call   388 <putc>
 5c9:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5cc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5d3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5d7:	8b 55 0c             	mov    0xc(%ebp),%edx
 5da:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5dd:	01 d0                	add    %edx,%eax
 5df:	0f b6 00             	movzbl (%eax),%eax
 5e2:	84 c0                	test   %al,%al
 5e4:	0f 85 94 fe ff ff    	jne    47e <printf+0x22>
    }
  }
}
 5ea:	90                   	nop
 5eb:	90                   	nop
 5ec:	c9                   	leave
 5ed:	c3                   	ret

000005ee <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5ee:	55                   	push   %ebp
 5ef:	89 e5                	mov    %esp,%ebp
 5f1:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5f4:	8b 45 08             	mov    0x8(%ebp),%eax
 5f7:	83 e8 08             	sub    $0x8,%eax
 5fa:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5fd:	a1 b0 0a 00 00       	mov    0xab0,%eax
 602:	89 45 fc             	mov    %eax,-0x4(%ebp)
 605:	eb 24                	jmp    62b <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 607:	8b 45 fc             	mov    -0x4(%ebp),%eax
 60a:	8b 00                	mov    (%eax),%eax
 60c:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 60f:	72 12                	jb     623 <free+0x35>
 611:	8b 45 f8             	mov    -0x8(%ebp),%eax
 614:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 617:	72 24                	jb     63d <free+0x4f>
 619:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61c:	8b 00                	mov    (%eax),%eax
 61e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 621:	72 1a                	jb     63d <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 623:	8b 45 fc             	mov    -0x4(%ebp),%eax
 626:	8b 00                	mov    (%eax),%eax
 628:	89 45 fc             	mov    %eax,-0x4(%ebp)
 62b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62e:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 631:	73 d4                	jae    607 <free+0x19>
 633:	8b 45 fc             	mov    -0x4(%ebp),%eax
 636:	8b 00                	mov    (%eax),%eax
 638:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 63b:	73 ca                	jae    607 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 63d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 640:	8b 40 04             	mov    0x4(%eax),%eax
 643:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 64a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64d:	01 c2                	add    %eax,%edx
 64f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 652:	8b 00                	mov    (%eax),%eax
 654:	39 c2                	cmp    %eax,%edx
 656:	75 24                	jne    67c <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 658:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65b:	8b 50 04             	mov    0x4(%eax),%edx
 65e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 661:	8b 00                	mov    (%eax),%eax
 663:	8b 40 04             	mov    0x4(%eax),%eax
 666:	01 c2                	add    %eax,%edx
 668:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66b:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 66e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 671:	8b 00                	mov    (%eax),%eax
 673:	8b 10                	mov    (%eax),%edx
 675:	8b 45 f8             	mov    -0x8(%ebp),%eax
 678:	89 10                	mov    %edx,(%eax)
 67a:	eb 0a                	jmp    686 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 67c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67f:	8b 10                	mov    (%eax),%edx
 681:	8b 45 f8             	mov    -0x8(%ebp),%eax
 684:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 686:	8b 45 fc             	mov    -0x4(%ebp),%eax
 689:	8b 40 04             	mov    0x4(%eax),%eax
 68c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 693:	8b 45 fc             	mov    -0x4(%ebp),%eax
 696:	01 d0                	add    %edx,%eax
 698:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 69b:	75 20                	jne    6bd <free+0xcf>
    p->s.size += bp->s.size;
 69d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a0:	8b 50 04             	mov    0x4(%eax),%edx
 6a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a6:	8b 40 04             	mov    0x4(%eax),%eax
 6a9:	01 c2                	add    %eax,%edx
 6ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ae:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b4:	8b 10                	mov    (%eax),%edx
 6b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b9:	89 10                	mov    %edx,(%eax)
 6bb:	eb 08                	jmp    6c5 <free+0xd7>
  } else
    p->s.ptr = bp;
 6bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6c3:	89 10                	mov    %edx,(%eax)
  freep = p;
 6c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c8:	a3 b0 0a 00 00       	mov    %eax,0xab0
}
 6cd:	90                   	nop
 6ce:	c9                   	leave
 6cf:	c3                   	ret

000006d0 <morecore>:

static Header*
morecore(uint nu)
{
 6d0:	55                   	push   %ebp
 6d1:	89 e5                	mov    %esp,%ebp
 6d3:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6d6:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6dd:	77 07                	ja     6e6 <morecore+0x16>
    nu = 4096;
 6df:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6e6:	8b 45 08             	mov    0x8(%ebp),%eax
 6e9:	c1 e0 03             	shl    $0x3,%eax
 6ec:	83 ec 0c             	sub    $0xc,%esp
 6ef:	50                   	push   %eax
 6f0:	e8 7b fc ff ff       	call   370 <sbrk>
 6f5:	83 c4 10             	add    $0x10,%esp
 6f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6fb:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6ff:	75 07                	jne    708 <morecore+0x38>
    return 0;
 701:	b8 00 00 00 00       	mov    $0x0,%eax
 706:	eb 26                	jmp    72e <morecore+0x5e>
  hp = (Header*)p;
 708:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 70e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 711:	8b 55 08             	mov    0x8(%ebp),%edx
 714:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 717:	8b 45 f0             	mov    -0x10(%ebp),%eax
 71a:	83 c0 08             	add    $0x8,%eax
 71d:	83 ec 0c             	sub    $0xc,%esp
 720:	50                   	push   %eax
 721:	e8 c8 fe ff ff       	call   5ee <free>
 726:	83 c4 10             	add    $0x10,%esp
  return freep;
 729:	a1 b0 0a 00 00       	mov    0xab0,%eax
}
 72e:	c9                   	leave
 72f:	c3                   	ret

00000730 <malloc>:

void*
malloc(uint nbytes)
{
 730:	55                   	push   %ebp
 731:	89 e5                	mov    %esp,%ebp
 733:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 736:	8b 45 08             	mov    0x8(%ebp),%eax
 739:	83 c0 07             	add    $0x7,%eax
 73c:	c1 e8 03             	shr    $0x3,%eax
 73f:	83 c0 01             	add    $0x1,%eax
 742:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 745:	a1 b0 0a 00 00       	mov    0xab0,%eax
 74a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 74d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 751:	75 23                	jne    776 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 753:	c7 45 f0 a8 0a 00 00 	movl   $0xaa8,-0x10(%ebp)
 75a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 75d:	a3 b0 0a 00 00       	mov    %eax,0xab0
 762:	a1 b0 0a 00 00       	mov    0xab0,%eax
 767:	a3 a8 0a 00 00       	mov    %eax,0xaa8
    base.s.size = 0;
 76c:	c7 05 ac 0a 00 00 00 	movl   $0x0,0xaac
 773:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 776:	8b 45 f0             	mov    -0x10(%ebp),%eax
 779:	8b 00                	mov    (%eax),%eax
 77b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 77e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 781:	8b 40 04             	mov    0x4(%eax),%eax
 784:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 787:	72 4d                	jb     7d6 <malloc+0xa6>
      if(p->s.size == nunits)
 789:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78c:	8b 40 04             	mov    0x4(%eax),%eax
 78f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 792:	75 0c                	jne    7a0 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 794:	8b 45 f4             	mov    -0xc(%ebp),%eax
 797:	8b 10                	mov    (%eax),%edx
 799:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79c:	89 10                	mov    %edx,(%eax)
 79e:	eb 26                	jmp    7c6 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a3:	8b 40 04             	mov    0x4(%eax),%eax
 7a6:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7a9:	89 c2                	mov    %eax,%edx
 7ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ae:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b4:	8b 40 04             	mov    0x4(%eax),%eax
 7b7:	c1 e0 03             	shl    $0x3,%eax
 7ba:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c0:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7c3:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c9:	a3 b0 0a 00 00       	mov    %eax,0xab0
      return (void*)(p + 1);
 7ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d1:	83 c0 08             	add    $0x8,%eax
 7d4:	eb 3b                	jmp    811 <malloc+0xe1>
    }
    if(p == freep)
 7d6:	a1 b0 0a 00 00       	mov    0xab0,%eax
 7db:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7de:	75 1e                	jne    7fe <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 7e0:	83 ec 0c             	sub    $0xc,%esp
 7e3:	ff 75 ec             	push   -0x14(%ebp)
 7e6:	e8 e5 fe ff ff       	call   6d0 <morecore>
 7eb:	83 c4 10             	add    $0x10,%esp
 7ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7f5:	75 07                	jne    7fe <malloc+0xce>
        return 0;
 7f7:	b8 00 00 00 00       	mov    $0x0,%eax
 7fc:	eb 13                	jmp    811 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 801:	89 45 f0             	mov    %eax,-0x10(%ebp)
 804:	8b 45 f4             	mov    -0xc(%ebp),%eax
 807:	8b 00                	mov    (%eax),%eax
 809:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 80c:	e9 6d ff ff ff       	jmp    77e <malloc+0x4e>
  }
}
 811:	c9                   	leave
 812:	c3                   	ret
