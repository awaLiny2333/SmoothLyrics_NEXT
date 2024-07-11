import { systemDateTime } from '@kit.BasicServicesKit';
import display from '@ohos.display';

@Entry
@Component
struct Index {
  @State PLAY_start_time: number = -1
  @State PLAY_now_play_time_ms: number = 0
  @State PLAY_now_playing: boolean = false
  @State PLAY_now_play_to_line: number = 0
  @State DESIGN_highlight_color: string = "#fffdfcf4"
  @State DATA_lrc: string =
    "[ti:我的梦][ar:张靓颖][al:华为消费者业务品牌主题曲][00:00.00]我的梦 - 张靓颖[00:01.00]作词：王海涛、张靓颖[00:02.00]作曲：Andy Love[00:03.00]编曲：崔迪[00:07.00][00:08.22]一直地 一直地 往前走[00:12.46]疯狂的世界[00:16.55]迎着痛 把眼中 所有梦[00:20.75]都交给时间[00:23.47]想飞 就用心地去飞[00:26.65]谁不经历狼狈[00:30.70]我想我会 忽略失望的灰[00:34.71]拥抱遗憾的美[00:38.70]我的梦说别停留等待[00:43.75]就让光芒折射泪湿的瞳孔[00:47.33]映出心中最想拥有的彩虹[00:51.41]带我奔向那片有你的天空[00:55.35]因为你是我的梦[01:01.10][01:06.33]我的梦[01:08.94][01:16.42]执著地 勇敢地 不回头[01:20.32]穿过了黑夜 踏过了边界[01:24.37]路过雨 路过风 往前冲[01:28.40]总会有一天 站在你身边[01:31.83]泪 就让它往下坠[01:34.64]溅起伤口的美[01:38.68]别以为 失去的最宝贵[01:42.63]才让今天浪费[01:46.71]我的梦说别停留等待[01:51.40]就让光芒折射泪湿的瞳孔[01:55.29]映出心中最想拥有的彩虹[01:59.26]带我奔向那片有你的天空[02:03.18]因为你是我的梦[02:09.27]我的梦[02:17.51][02:23.36]世界会怎么变化[02:25.93]都不是意外[02:28.11]记得用心去回答[02:30.11]命运的精彩[02:32.04]世界会怎么变化[02:34.07]都离不开爱[02:35.90]记得成长的对话[02:37.96]勇敢地说 我不再等待[02:45.38]就让光芒折射泪湿的瞳孔[02:49.25]映出心中最想拥有的彩虹[02:53.25]带我奔向那片有你的天空[02:57.20]因为你是我的梦[03:03.61]我的梦 我的梦[03:13.03]因为你是我的梦"
  @State DATA_time_stamps_from: number[] = []
  @State DATA_time_stamps_to: number[] = []
  @State DATA_lyric_texts: string[] = []
  @State DATA_lyric_lines_count: number[] = []
  @State CONTROL_user_swiping: boolean = false

  aboutToAppear() {
    console.log("TIMER: START!")
    setInterval(() => {
      if (this.PLAY_now_playing) {
        this.PLAY_now_play_time_ms = systemDateTime.getTime() - this.PLAY_start_time
        if (this.DATA_time_stamps_to[this.PLAY_now_play_to_line] < this.PLAY_now_play_time_ms) {
          this.PLAY_now_play_to_line += 1
          this.onSwitchLine()
        }
      }
    }, 10);

    console.log(this.DATA_lrc)
    this.LRC_load_plain_string(this.DATA_lrc)
  }

  build() {
    RelativeContainer() {
      RelativeContainer() {
        ForEach(this.DATA_time_stamps_from, (item: number, index: number) => {
          Lyric_Line({
            DATA_text: this.DATA_lyric_texts[index],
            DATA_lines_height: this.DATA_lyric_lines_count,
            PLAY_now_play_time_ms: this.PLAY_now_play_time_ms,
            PLAY_now_playing_line: this.PLAY_now_play_to_line,
            PLAY_now_playing: this.PLAY_now_playing,
            DESIGN_font_color: this.DESIGN_highlight_color,
            UI_index: index,
          })
        })
      }
      .margin({ top: 200 })

      Row() {
        Text(this.PLAY_now_play_to_line.toString() + " ")
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)
          .fontColor(this.DESIGN_highlight_color)
        Text((this.PLAY_now_play_time_ms / 1000).toFixed(3))
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Start)
          .fontColor(this.DESIGN_highlight_color)
          .margin({ left: 20 })
        Row() {
          SymbolGlyph(!this.PLAY_now_playing ? $r('sys.symbol.play_circle_fill') :
          $r('sys.symbol.pause_round_triangle_fill'))
            .fontSize(60)
            .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), Number(this.PLAY_now_playing))
            .fontColor([this.DESIGN_highlight_color])
            .onClick(() => {
              this.PLAY_now_playing = !this.PLAY_now_playing
              this.PLAY_start_time = systemDateTime.getTime()
              if (!this.PLAY_now_playing) {
              } else {
                this.PLAY_now_play_time_ms = 0
                this.PLAY_now_play_to_line = 0
                // Reset timer
                this.onSwitchLine()
              }
            })
        }
      }
      .alignItems(VerticalAlign.Bottom)
      .margin(20)
      .alignRules({
        bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
      })
    }
    .backgroundImage($r('app.media.home_backdrop'))
    .backgroundImageSize(ImageSize.Cover)
    .backgroundEffect({
      brightness: 0.8,
      radius: 120
    })
    .height('100%')
    .width('100%')
  }

  UTIL_Resource_To_String(resource: Resource): string {
    return getContext(this).resourceManager.getStringSync(resource)
  }

  LRC_load_plain_string(string: string) {
    let original = string.split("[").slice(1)
    let line: string[] = []

    let screen_width = display.getDefaultDisplaySync().width
    let break_length = Math.floor(screen_width / 140)

    this.DATA_time_stamps_from = []
    this.DATA_time_stamps_to = []
    this.DATA_lyric_texts = []
    this.DATA_lyric_lines_count = []

    for (let index = 0; index < original.length; index++) {
      line = original[index].split("]")
      if (!"abcdefghijklmnopqrstuvwxyz".includes(line[0][0])) {
        // if is time marks

        let text = line[1]
        if (text == "") {
          this.DATA_lyric_texts.push("···")
          this.DATA_lyric_lines_count.push(1)

        } else {
          let text_split: string[] = text.split("")
          let text_sep = Math.floor(text.length / break_length)
          // Calculate count of line breaks
          this.DATA_lyric_lines_count.push(text_sep + 1)

          for (let k = 1; k <= text_sep; k++) {
            let target_insert_position = k * break_length
            while ("abcdefghijklmnopqrstuvwxyz".includes(text_split[target_insert_position])) {
              target_insert_position += 1
            }
            text_split.splice(target_insert_position, 0, "\n")
            // Insert returns
            if (text_split[target_insert_position + 1] == " ") {
              text_split[target_insert_position + 1] = text_split[target_insert_position + 1].substring(1)
              // Eliminate Spaces in the front
            }
          }

          if (text_split[text_split.length -1] == "\n") {
            text_split.splice(text_split.length - 1, 1)
            this.DATA_lyric_lines_count[this.DATA_lyric_lines_count.length -1] = text_sep
          }

          text = text_split.join("")

          this.DATA_lyric_texts.push(text)
        }
        // Push Text

        line = line[0].split(":")
        // Split time

        let this_line_time_stamp = (Number(line[0]) * 60 + Number(line[1])) * 1000

        if (this.DATA_time_stamps_from.length > 0) {
          this.DATA_time_stamps_to.push(this_line_time_stamp - 1)
          // Set time ends for the previous line
        }

        this.DATA_time_stamps_from.push(this_line_time_stamp)
        // translate all mm:ss.ss into ms

      } else {
        // if is text information
      }
    }
    this.DATA_time_stamps_to.push(100 * 60 * 1000)
    console.log(this.DATA_lyric_lines_count.toString())
  }

  onSwitchLine() {
  }
}

@Component
struct Lyric_Line {
  @State DATA_text: string = "Lyric meow"
  @State DATA_lines_height: number[] = []
  @State DESIGN_font_color: string = "#FFFFFF"
  @Prop PLAY_now_play_time_ms: number = 0
  @Prop PLAY_now_playing_line: number = 0
  @Prop PLAY_now_playing: boolean = false
  @State UI_font_size: number = 22
  @State UI_index: number = 0
  @State UI_animation_duration: number = 0

  build() {
    Text(this.DATA_text)
      .fontWeight(this.PLAY_playing_this_line() ? FontWeight.Bolder : FontWeight.Bold)
      .fontSize(26)
      .blur(this.UI_blur_radius())
      .animation({
        duration: (this.PLAY_now_playing_line > this.UI_index ? 200 : 500),
      })

      .opacity(this.UI_opacity())
      .offset({ y: this.UI_offset() })
      .animation({ delay: this.UI_delay(), duration: 500, curve: Curve.ExtremeDeceleration })


      .textAlign(TextAlign.Start)
      .fontColor(this.DESIGN_font_color)
      .width("100%")
      .padding({
        left: 20,
        right: 20,
        bottom: 10,
        top: 10
      })
      .height(this.DATA_lines_height[this.UI_index] * 36 + 20)
  }

  PLAY_playing_this_line() {
    let is_playing = this.PLAY_now_playing_line == this.UI_index
    return is_playing
  }

  UI_blur_radius() {
    let difference = this.UI_index - this.PLAY_now_playing_line

    if (difference > 8 || difference < -3) {
      // Save performance
      return 0
    }

    if (difference < 0) {
      return 10
    }

    if (difference == 0) {
      return 0
    }
    return 3 + Math.min(difference * 2.5, 30)
  }

  UI_offset() {
    let offset = 0

    if (this.UI_index - this.PLAY_now_playing_line == -1) {
      offset -= (this.DATA_lines_height[this.UI_index] * 36 + 20)
    } else if (this.UI_index - this.PLAY_now_playing_line < -1) {
      offset -= ((this.DATA_lines_height[this.UI_index] + this.DATA_lines_height[this.UI_index + 1]) * 36 + 20)
    } else if (this.UI_index > this.PLAY_now_playing_line) {
      for (let index = this.PLAY_now_playing_line; index < this.UI_index; index++) {
        offset += this.DATA_lines_height[index] * 36 + 20
      }
    }

    return offset
  }

  UI_delay() {
    return Math.max((this.UI_index - this.PLAY_now_playing_line) * 70, 0)
  }

  UI_visible() {
    if (this.PLAY_now_playing_line - this.UI_index <= 1 && this.PLAY_now_playing_line - this.UI_index >= -8) {
      return true
    } else {
      return false
    }
  }

  UI_opacity() {
    if (this.UI_visible()) {
      return this.PLAY_playing_this_line() ? 1 : 0.2
    }
    return 0
  }
}

