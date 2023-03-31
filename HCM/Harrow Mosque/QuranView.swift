import SwiftUI
import AVKit

struct QuranView: View {
    @ObservedObject var dataSurah = ApiServices()

    var body: some View {
        NavigationView {
            if #available(iOS 15.0, *) {
                content
                    .navigationBarTitle("Qur'an")
                    .environment(\.defaultMinListRowHeight, 110)
                    .listStyle(InsetGroupedListStyle())
                    .environment(\.horizontalSizeClass, .regular)
            } else {
                content
            }
        }
        .offset(y: -60)
        .padding(.bottom, -20)
        .padding(.top, 26)
    }

    @ViewBuilder
    private var content: some View {
        List {
            ForEach(dataSurah.surahData) { surah in
                Section {
                    NavigationLink(destination: SurahDetail(surahNumber: surah.number, title: surah.name)) {
                        HStack(spacing: 14) {
                            Text("\(surah.number)")
                                .foregroundColor(Color.primary)
                                .frame(width: 45, height: 45)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(surah.name)")
                                    .font(.headline)
                                Text("Surah \(surah.englishName)・\(surah.revelationType)")
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .padding([.leading, .trailing], 15)
            if dataSurah.isLoading {
                VStack {
                    Indicator()
                    Text("Loading...")
                }
                .shadow(color: Color.secondary.opacity(0.3), radius: 20)
            }
        }
        .padding(.bottom, 80)
    }
}

struct QuranView_Previews: PreviewProvider {
    static var previews: some View {
        QuranView()
    }
}

class SoundManager : ObservableObject {
    @Published var audioPlayer : AVPlayer?
    @Published var isPlaying : Bool = false
    
    func playAudio(sound : String){
        if let urlAudio = URL(string: sound){
            self.audioPlayer = AVPlayer(url: urlAudio)
            self.audioPlayer?.play()
            self.isPlaying = true
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
            
        }
        
    }
    
    func pauseAudio(){
        self.audioPlayer?.pause()
        self.isPlaying = false
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        self.isPlaying = false
    }
    
}



struct SurahDetail: View {
    let surahNumber: Int
    let title: String
    
    @State private var playButtonId = 0
    
    @ObservedObject private var surahFetch = SurahDetailServices()
    @ObservedObject private var soundManager = SoundManager()
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView(showsIndicators: false) {
                    ForEach(surahFetch.surahDetail) { data in
                        VStack {
                            VStack(alignment: .trailing) {
                                HStack {
                                    Spacer()
                                    Text(data.text)
                                        .multilineTextAlignment(.trailing)
                                }
                                
                                Button(action: {
                                    if soundManager.isPlaying {
                                        soundManager.pauseAudio()
                                        if playButtonId != data.id {
                                            soundManager.playAudio(sound: data.audio)
                                            playButtonId = data.id
                                        }
                                    } else {
                                        soundManager.playAudio(sound: data.audio)
                                        playButtonId = data.id
                                    }
                                }) {
                                    if #available(iOS 15.0, *) {
                                        if data.id == playButtonId && soundManager.isPlaying {
                                            Label("Audio", systemImage: "pause.fill")
                                                .padding([.top, .bottom], 5)
                                                .padding([.leading, .trailing], 14)
                                                .background(.ultraThinMaterial)
                                                .clipShape(RoundedRectangle(cornerRadius: 7))
                                        } else {
                                            Label("Audio", systemImage: "play.fill")
                                                .padding([.top, .bottom], 5)
                                                .padding([.leading, .trailing], 14)
                                                .background(.ultraThinMaterial)
                                                .clipShape(RoundedRectangle(cornerRadius: 7))
                                        }
                                    } else {
                                        if data.id == playButtonId && soundManager.isPlaying {
                                            HStack {
                                                Image(systemName: "pause.fill")
                                                Text("Audio")
                                            }
                                            .padding([.top, .bottom], 5)
                                            .padding([.leading, .trailing], 14)
                                            .clipShape(RoundedRectangle(cornerRadius: 7))
                                        } else {
                                            HStack {
                                                Image(systemName: "play.fill")
                                                Text("Audio")
                                            }
                                            .padding([.top, .bottom], 5)
                                            .padding([.leading, .trailing], 14)
                                            .clipShape(RoundedRectangle(cornerRadius: 7))
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 80)
                        }
                    }
                }
                .padding([.leading, .trailing], 14)
            }
            .padding(.bottom, 60)
            .padding(.top, 60)
        }
        .onAppear {
            surahFetch.getSurah(surahId: surahNumber)
        }
        .navigationTitle(title)
    }
}

/*
struct SurahDetail_Previews: PreviewProvider {
    static var previews: some View {
        SurahDetail(number: 0, title: "")
    }
}
 */

struct Indicator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = UIColor.lightGray
        return indicator
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.startAnimating()
    }
    
    typealias UIViewType = UIActivityIndicatorView
}
