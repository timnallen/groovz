require 'rails_helper'

RSpec.describe PlaylistSpotifyService do
  before :each do
    @user = create(:user, mode: 0.21, acousticness: 0.0337308434, danceability: 0.24806, energy: 0.38735, valence: 0.166571, tempo: 63.56895)
    create(:party, user: @user, users: [@user], playlist_id: '74Y6B6tpTtlX6mXtIDlaRI', device_id: '4c3c5c83a082baf4255e54cec7f9b61b595be57c', code: 'code')
    @service = PlaylistSpotifyService.new(@user)
  end

  it 'exists' do
    expect(@service).to be_a PlaylistSpotifyService
  end

  describe 'instance methods' do
    describe 'current_song' do
      it 'returns the current song being played for the user' do
        song = VCR.use_cassette('spec/current_song') do
          @service.current_song
        end

        expect(song).to be_a Hash
        expect(song).to have_key :name
        expect(song).to have_key :artists
        expect(song[:album][:artists][0]).to have_key :name
        expect(song[:album]).to have_key :images
      end
    end

    describe 'populate_playlist' do
      it 'populates a playlist based on the users current average tastes' do
        Artist.create(user: @user, artist_name: 'Disturbed', spotify_id: '3TOqt5oJwL9BE2NG9MEwDa')
        playlist = Party.create(user: @user, users: [@user], playlist_id: "2iyYsK01c4lPHyolL9lCqY", code: 'ABCDE')

        response = VCR.use_cassette('services/populate_playlist') do
          @service.populate_playlist(playlist.playlist_id)
        end

        expect(response.status).to eq(201)
      end
    end

    describe 'change_playlist_name' do
      it 'renames a playlist based on playlist name in party' do
        playlist = Party.create(user: @user, users: [@user], playlist_id: "2iyYsK01c4lPHyolL9lCqY", code: 'ABCDE', name: "Cool Playlist")

        response = VCR.use_cassette('services/rename_playlist') do
          @service.change_playlist_name(playlist.playlist_id, playlist.name)
        end

        expect(response.status).to eq(200)
      end
    end

    describe 'start_playback' do
      it 'starts playback of the generated playlist on the users device' do
        party = create(:party,
          playlist_id: '4ZenWelYqdG7lVhcDerX9D',
          device_id: '6f5333c011e9913b7ea319fdcc9f144e7e4329f2',
          user: @user,
          users: [@user]
        )

        VCR.use_cassette('services/start_playback') do
          @service.start_playback

          # new_song? triggers service call and inserts in to database
          expect(party.new_song?).to eq(true)
          expect(party.current_song.title).to eq('Silver Bullet')
        end
      end
    end
  end
end
