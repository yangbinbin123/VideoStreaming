#! /bin/sh
gcc simplest_ffmpeg_mem_player.cpp -g -o simplest_ffmpeg_mem_player.out -lstdc++ \
-I /usr/local/include -L /usr/local/lib -lSDLmain -lSDL -lavformat -lavcodec -lavutil -lswscale

TMD:
gcc simplest_ffmpeg_mem_player.cpp -o simplest_ffmpeg_mem_player -I/usr/local/ffmpeg/include -L/usr/local/ffmpeg/lib `sdl-config --cflags --libs` -lavformat -lavcodec -lavutil -lswscale
gcc 1.cpp -o simple -I/usr/local/ffmpeg/include -L/usr/local/ffmpeg/lib `sdl-config --cflags --libs` -lavformat -lavcodec -lavutil -lswscale
gcc 2.cpp -o 2 -I/usr/local/ffmpeg/include -L/usr/local/ffmpeg/lib `sdl-config --cflags --libs` -lavformat -lavcodec -lavutil -lswresample


gcc 7.cpp -o 7 -I/usr/local/ffmpeg/include -L/usr/local/ffmpeg/lib `sdl-config --cflags --libs` -lavformat -lavcodec -lavutil -lswscale


/////////////////////////////////////////////////////////////
const char*output_file_name="/root/123.avi";
AVOutputFormat *fmt;
AVFormatContext *oc;
AVCodecContext *oVcc=NULL,*oAcc=NULL;
AVCodec *oVc,*oAc;
AVStream *video_st,*audio_st;
AVFrame *oVFrame,*oAFrame;
double video_pts;
oVFrame=av_frame_alloc();
oAFrame=av_frame_alloc();
fmt=av_guess_format(NULL,output_file_name,NULL);
if(!fmt)
    {
           printf("could not deduce outputformat from outfile extension\n");
           exit(0);
    }//判断是否可以判断输出文件的编码格式
oc=avformat_alloc_context();
if(!oc)
    {
           printf("Memory error\n");
           exit(0);
    }
oc->oformat=fmt;
////////////////////////////////////////////////////////////
av_strlcpy(oc->filename,sizeof(oc->filename),output_file_name);
////////////////////////////////////////////////////////////
video_st=avformat_new_stream(oc,0);
if(!video_st)
    {
          printf("could not alloc videostream\n");
          exit(0);
    }
oVcc=video_st->codec;
oVcc->codec_id=AV_CODEC_ID_MPEG4;
oVcc->codec_type=AVMEDIA_TYPE_VIDEO;
oVcc->bit_rate=2500000;
oVcc->width=704;
oVcc->height=480;
oVcc->time_base=pCodecCtx->time_base;
oVcc->gop_size=pCodecCtx->gop_size;
oVcc->pix_fmt=pCodecCtx->pix_fmt;
oVcc->max_b_frames=pCodecCtx->max_b_frames;
video_st->r_frame_rate=pFormatCtx->streams[videoindex]->r_frame_rate;
audio_st=avformat_new_stream(oc,oc->nb_streams);
if(!audio_st)
    {
           printf("could not alloc audiostream\n");
           exit(0);
    } 
//avcodec_get_context_defaults2(audio_st->codec,AVMEDIA_TYPE_AUDIO);
oAcc=audio_st->codec;
oAcc->codec_id=AV_CODEC_ID_MP3;
oAcc->codec_type=AVMEDIA_TYPE_AUDIO;
oAcc->bit_rate=pCodecCtxa->bit_rate;
oAcc->sample_rate=pCodecCtxa->sample_rate;
oAcc->channels=2;
//if (av_set_parameters(oc, NULL) < 0)
//    {
//           printf( "Invalid output formatparameters\n");                        
//           exit(0);                              
//    }
//设置必要的输出参数
// strcpy(oc->title,pFormatCtx->title);
// strcpy(oc->author,pFormatCtx->author);
// strcpy(oc->copyright,pFormatCtx->copyright);
// strcpy(oc->comment,pFormatCtx->comment);
// ////////////////////////////////////////////////////
// strcpy(oc->album,pFormatCtx->album);
// oc->year=pFormatCtx->year;
// oc->track=pFormatCtx->track;
// strcpy(oc->genre,pFormatCtx->genre);
oVc=avcodec_find_encoder(AV_CODEC_ID_MPEG4);
    if(!oVc)
    {
       printf("can't find suitable videoencoder\n");
       exit(0);
    }//找到合适的视频编码器
    if(avcodec_open2(oVcc,oVc,NULL)<0)
    {
           printf("can't open the outputvideo codec\n");
           exit(0);
    }//打开视频编码器
    oAc=avcodec_find_encoder(AV_CODEC_ID_MP3);
    if(!oAc)
    {
           printf("can't find suitableaudio encoder\n");
           exit(0);
    }//找到合适的音频编码器
    if(avcodec_open2(oAcc,oAc,NULL)<0)
    {
           printf("can't open the outputaudio codec");
           exit(0);
    }//打开音频编码器
    if (!(oc->flags & AVFMT_NOFILE))
    {
      if(avio_open2(&oc->pb,output_file_name,AVIO_FLAG_READ_WRITE,NULL,NULL)<0)
       {
              printf("can't open theoutput file %s\n",output_file_name);
              exit(0);
       }//打开输出文件
    }

    if(!oc->nb_streams)
    {
           fprintf(stderr,"output filedose not contain any stream\n");
           exit(0);
    }//查看输出文件是否含有流信息

  if(avformat_write_header(oc,NULL)<0)
  {
      fprintf(stderr, "Could not writeheader for output file\n");
      exit(1);
  }
  AVPacket packet;
  uint8_t *ptr,*out_buf;
  int out_size;
  static short *samples=NULL;
  static unsigned int samples_size=0;
  uint8_t *video_outbuf,*audio_outbuf;int video_outbuf_size,audio_outbuf_size;
  video_outbuf_size=400000;
  video_outbuf= (unsigned char *)malloc(video_outbuf_size);
  audio_outbuf_size = 10000;
  audio_outbuf = av_malloc(audio_outbuf_size);
  int flag;
  int frameFinished;
  int len;
  int frame_index=0,ret;
  while(av_read_frame(pFormatCtx,&packet)>=0)//从输入文件中读取一个包
  {
     if(packet.stream_index==videoindex)//判断是否为当前视频流中的包
     {
/////////////////////////////////////////////////////////////////////
       len=avcodec_decode_video2(pCodecCtx,oVFrame,&frameFinished,&packet);//若为视频包，解码该视频包
                 if(len<0)
////////////////////////////////////////////////////////////
                 {
                    printf("Error whiledecoding\n");
                    exit(0);
                 }
         if(frameFinished)//判断视频祯是否读完
         {
             fflush(stdout);
             oVFrame->pts=av_rescale(frame_index,AV_TIME_BASE*(int64_t)oVcc->time_base.num,oVcc->time_base.den);
             oVFrame->pict_type=0;
             out_size =avcodec_encode_video2(oVcc, video_outbuf, video_outbuf_size, oVFrame);  
             if (out_size > 0)           
             {                  
                 AVPacket pkt;              
                 av_init_packet(&pkt);                              
                 if(oVcc->coded_frame&& oVcc->coded_frame->key_frame)                                      
                     pkt.flags |=AV_PKT_FLAG_KEY;                                       
                     pkt.flags =packet.flags;                     
                     pkt.stream_index=video_st->index;                                               
                     pkt.data=video_outbuf;                                                        
                     pkt.size= out_size;                                            
                     ret=av_write_frame(oc,&pkt);                                       
             }
             frame_index++;
         }
         else
             ret=av_write_frame(oc,&packet);
          if(ret!=0)
              {
                      printf("while writevideo frame error\n");
                      exit(0);
                    }
          }
      else if(packet.stream_index==audioindex)
      {

         len=packet.size;
         ptr=packet.data;
             int ret=0;
             while(len>0)
             {
                    out_buf=NULL;
                    out_size=0;
             if(&packet)
              samples=av_fast_realloc(samples,&samples_size,FFMAX(packet.size*sizeof(*samples),AVCODEC_MAX_AUDIO_FRAME_SIZE));
              out_size=samples_size;
              ret=avcodec_decode_audio4(pCodecCtxa,oAFrame,&out_size,&packet);//若为音频包，解码该音频包
                    if(ret<0)
                    {
                       printf("whiledecode audio failure\n");
                       exit(0);
                    }
            fflush(stdout);
            ptr+=ret;
            len-=ret;
            if(out_size<=0)
               continue;
            out_buf=(uint8_t *)samples;
            AVPacket pkt;
            av_init_packet(&pkt);
            pkt.size=avcodec_encode_audio2(oAcc, audio_outbuf, audio_outbuf_size, out_buf);
            pkt.pts=av_rescale_q(oAcc->coded_frame->pts, oAcc->time_base,audio_st->time_base);
            pkt.flags |= AV_PKT_FLAG_KEY;
            pkt.stream_index= audioindex;
            pkt.data= audio_outbuf;
            if (av_write_frame(oc, &pkt) !=0)
            {
               fprintf(stderr, "Errorwhile writing audio frame\n");
               exit(1);
                }
         }
         }
          av_free_packet(&packet);
       }

av_write_trailer(oc);
for(i= 0; i < oc->nb_streams; i++)
{           
 av_freep(&oc->streams[i]->codec);                      
 av_freep(&oc->streams[i]);                          
}
avformat_close_input(&oc);
av_free(oc);
av_free(oVFrame);
av_free(out_buf);
avcodec_close(pCodecCtx);
avcodec_close(pCodecCtxa);
avformat_close_input(&pFormatCtx);
}