# frozen_string_literal: true

class PartyTrackSerializer
  include FastJsonapi::ObjectSerializer
  attributes :spotify_id, :img_url, :title, :artist
end
