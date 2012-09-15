################################################
# 排他的に動画をエンコさせるスクリプト         #
# pidファイル管理で、重複起動時はスリープする  #
# 複数ファイル指定でも順番に処理される         #
# tabstop=4                                    #
################################################

my $workdir = "${0}_work";         # 作業ディレクトリ
my $pfile = "$workdir/running.pid"; # 重複でプロセスが動かないように。
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
    # エンコードするファイルを表示
    warn @ARGV,"\n";
    print "open\n";
    open(F, "> $pfile") or next;
    flock(F, 2) or next;
    print F "$ARGV[0] encode start\n";
    $inputfile = $ARGV[0];
    $outputfile = $ARGV[0];
    $outputfile =~ s/\.[^.]+$/.mp4/g; # 拡張子変換
    $other_options = "--preset=Normal";
    system("$encode_soft_path -i \"$inputfile\" -o \"$outputfile\" $other_options");
    close(F); # 自動でロックも解除する
    unlink $pfile;
    shift @ARGV;
}
