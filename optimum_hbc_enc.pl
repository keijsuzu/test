################################################
# 排他的に動画をエンコさせるスクリプト         #
# pidファイル管理で、重複起動時はスリープする  #
# 複数ファイル指定でも順番に処理される         #
################################################

my $workdir = "${0}_work";         # 作業ディレクトリ
my $pfile = "$workdir/running.pid"; # 重複でプロセスが動かないように。
my $rundum_time = 10;              # ランダムの最大時間 -1秒
my $encode_soft_path = 'C:"Program Files (x86)"\\Handbrake\\HandBrakeCLI.exe';

# 強制終了時にpfileを消すようにする
$SIG{'INT'} = $SIG{'HUP'} = $SIG{'QUIT'} = $SIG{'TERM'} = "sigexit";
sub sigexit {
    # この部分に作業ファイル削除などの終了処理を記述する
    if ( -f $pfile ) {
        unlink $pfile;
    }
}

unless ( -d $workdir ) {
    mkdir $workdir;
    warn "work dir created\n";
}

# 複数ファイルを引数にした場合順番に処理
warn @ARGV,"\n";
while (@ARGV) {
    if ( -f $pfile ) {
        sleep int(rand 10);
    } else {
		# エンコードするファイルを表示
        warn @ARGV,"\n";
        print "open\n";
        open(F, "> $pfile") or next;
        flock(F, 6) or next;
        print F "$ARGV[0] encode start\n";
        $inputfile = $ARGV[0];
        $outputfile = $ARGV[0];
        $outputfile =~ s/\.ts$/.mp4/g;
        $other_options = "-e x264 --keep-display-aspect --no-dvdnav --cfr";
        system("$encode_soft_path -i \"$inputfile\" -o \"$outputfile\" $other_options");
        flock(F, 8);
        close(F);
        unlink $pfile;
        shift @ARGV;
    }
}
