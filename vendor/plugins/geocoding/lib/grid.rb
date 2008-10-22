# grid.rb by David Troy (C) 2008
# implements USNG-NAD83 USA and MGRS-WGS84
#
# Based on C code originally written by
# Chuck Gantz - chuck.gantz@globalstar.com
#
# NOTE: this is not a full implementation of MGRS.
# It won't deal with numbers near the poles, but only
# in the UTM domain of 84N to 80S
#
# Reference ellipsoids derived from Peter H. Dana's website- 
# http://www.utexas.edu/depts/grg/gcraft/notes/datum/elist.html
# Department of Geography, University of Texas at Austin
# Internet: pdana@mail.utexas.edu
# 3/22/95
# 
# Source
# Defense Mapping Agency. 1987b. DMA Technical Report: Supplement to Department of Defense World Geodetic System
# 1984 Technical Report. Part I and II. Washington, DC: Defense Mapping Agency

include Math

module Geo
  module Grid

    # Constants
    FOURTHPI    = PI / 4
    DEG_2_RAD   = PI / 180
    RAD_2_DEG   = 180.0 / PI
    BLOCK_SIZE  = 100000 # size of square identifier (within grid zone designation), (meters)
    GRIDSQUARE_SET_COL_SIZE = 8  # column width of grid square set  
    GRIDSQUARE_SET_ROW_SIZE = 20 # row height of grid square set
    EQUATORIAL_RADIUS    = 6378137.0 # GRS80 ellipsoid (meters)
    ECC_SQUARED = 0.006694380023

    EASTING_OFFSET  = 500000.0   # (meters)
    NORTHING_OFFSET = 10000000.0 # (meters)
    K0 = 0.9996

    ECC_PRIME_SQUARED = ECC_SQUARED / (1.0 - ECC_SQUARED)
    E1 = (1.0 - sqrt(1.0 - ECC_SQUARED)) / (1.0 + sqrt(1.0 - ECC_SQUARED))

    # Number of digits to display for x,y coords
    #  no digits:    100km precision      eg  "18S UJ"
    #  One digit:    10 km precision      eg. "18S UJ 2 1"
    #  Two digits:   1 km precision       eg. "18S UJ 23 06"
    #  Three digits: 100 meters precision eg. "18S UJ 234 064"
    #  Four digits:  10 meters precision  eg. "18S UJ 2348 0647"
    #  Five digits:  1 meter precision    eg. "18S UJ 23480 06470"

    # /************* retrieve zone number from latitude, longitude *************
    # 
    #     Zone number ranges from 1 - 60 over the range [-180 to +180]. Each
    #     range is 6 degrees wide. Special cases for points outside normal
    #     [-80 to +84] latitude zone.
    # 
    # *************************************************************************/

    def get_zone_number(lat, lon)

      lat = lat.to_f
      lon = lon.to_f

      # convert 0-360 to [-180 to 180] range
      lonTemp = (lon + 180) - ((lon + 180) / 360).to_i * 360.0 - 180.0
      return ((lonTemp + 180.0) / 6.0).to_i + 1

      # Handle special case of west coast of Norway
      zone_number = 32 if ( (56...64)===lat && (3...12)===lonTemp )

      # Special zones for Svalbard
      if (72...84)===lat
        zone_number = case lonTemp
          when 0...9 then 31
          when 9...21 then 33
          when 21...33 then 35
          when 33...42 then 37
        end
      end
  
      zone_number
    end


    # /************** retrieve grid zone designator letter **********************
    # 
    #     This routine determines the correct UTM letter designator for the given 
    #     latitude returns 'Z' if latitude is outside the UTM limits of 84N to 80S
    # 
    #     Returns letter designator for a given latitude. 
    #     Letters range from C (-80 lat) to X (+84 lat), with each zone spanning
    #     8 degrees of latitude.
    # 
    # ***************************************************************************/

    def utm_letter_designator(lat)
      case lat
        when 72..84    then 'X'
        when 64...72   then 'W'
        when 56...64   then 'V'
        when 48...56   then 'U'
        when 40...48   then 'T'
        when 32...40   then 'S'
        when 24...32   then 'R'
        when 16...24   then 'Q'
        when 8...16    then 'P'
        when 0...8     then 'N'
        when -8...0    then 'M'
        when -16...-8  then 'L'
        when -24...-16 then 'K'
        when -32...-24 then 'J'
        when -40...-32 then 'H'
        when -48...-40 then 'G'
        when -56...-48 then 'F'
        when -64...-56 then 'E'
        when -72...-64 then 'D'
        when -80...-72 then 'C'
        else 'Z'
      end
    end

    class Point
      attr_reader :lat, :lon
      def initialize(params)
        if params[:lat] && params[:lon]
          @lat = params[:lat].to_f
          @lon = params[:lon].to_f
        elsif params[:utm]
          @lat, @lon = utm_to_ll(*params[:utm])
        end
      end
      
      def to_s
        "#{@lat} #{@lon}"
      end
      
      def to_utm
        @utm ||= Point::UTM.new(@lat, @lon)
      end
      
      def to_usng(precision=5)
        self.to_utm.to_usng(precision)
      end
      
      def to_mgrs(precision=5)
        self.to_usng(precision).to_mgrs
      end
      
      def ==(other)        
        other.lat.decimals(2)==@lat.decimals(2) && other.lon.decimals(2)==@lon.decimals(2)
      end
    
      private
      # UTM can only exist as a subclass of a point
      class UTM < Point
        attr_reader :gzd, :easting, :northing
      
        def initialize(lat, lon)
          @gzd, @easting, @northing = ll_to_utm(lat, lon)
        end
      
        def to_a
          [@gzd, @easting, @northing]
        end
      
        def to_usng(precision=5)
          USNG.new(@gzd, @northing, @easting, precision)
        end
        
        # USNG is a subclass of UTM
        class USNG < UTM
          def initialize(gzd, northing, easting, precision)
            @gzd = gzd
            @letters  = find_grid_letters(gzd, northing, easting)
            @northing = (northing.round % BLOCK_SIZE).to_s[0,precision]
            @easting  = (easting.round  % BLOCK_SIZE).to_s[0,precision]
          end

          def to_s
            "#{@gzd} #{@letters} #{@easting} #{@northing}"
          end

          def to_a
            [@gzd, @letters, @easting, @northing]
          end

          def to_mgrs
            @mgrs ||= to_s.gsub(/ /,'')
          end
        end
      
      end      
    end
    

    # /***************** convert latitude, longitude to UTM  *******************
    # 
    #     Converts lat/long to UTM coords.  Equations from USGS Bulletin 1532 
    #     (or USGS Professional Paper 1395 "Map Projections - A Working Manual", 
    #     by John P. Snyder, U.S. Government Printing Office, 1987.)
    #  
    #     East Longitudes are positive, West longitudes are negative. 
    #     North latitudes are positive, South latitudes are negative
    #     lat and lon are in decimal degrees
    # 
    #     output is in the input array utmcoords
    #         utmcoords[0] = easting
    #         utmcoords[1] = northing (NEGATIVE value in southern hemisphere)
    #         utmcoords[2] = zone
    # 
    # ***************************************************************************/
    def ll_to_utm(lat,lon)
      lat = lat.to_f
      lon = lon.to_f

      # Constrain reporting USNG coords to the latitude range [80S .. 84N]
      return nil unless (-80..84)===lat

      # Sanity check inputs
      return nil unless (-180..360)===lon && (-90..90)===lat

      # Convert values on 0-360 range to this range.
      lonTemp = (lon + 180.0) - ((lon + 180.0) / 360.0).to_i * 360.0 - 180.0
      latRad = lat     * DEG_2_RAD
      lonRad = lonTemp * DEG_2_RAD

      zone_number = get_zone_number(lat, lon)
      lonOrigin = (zone_number - 1.0) * 6.0 - 180.0 + 3.0  # +3 puts origin in middle of zone
      lonOriginRad = lonOrigin * DEG_2_RAD

      # compute the UTM Zone from the latitude and longitude
      utm_zone = zone_number.to_s + utm_letter_designator(lat)

      n = EQUATORIAL_RADIUS / sqrt(1.0 - ECC_SQUARED * sin(latRad) * sin(latRad))
      t = tan(latRad) * tan(latRad)
      c = ECC_PRIME_SQUARED * cos(latRad) * cos(latRad)
      a = cos(latRad) * (lonRad - lonOriginRad)

      # note that the term mo drops out of the "m" equation, because phi 
      # (latitude crossing the central meridian, lambda0, at the origin of the
      #  x,y coordinates), is equal to zero for Utm.
      m = EQUATORIAL_RADIUS * (( 1.0 - ECC_SQUARED / 4.0 -
            3.0 * (ECC_SQUARED * ECC_SQUARED) / 64.0 -
            5.0 * (ECC_SQUARED * ECC_SQUARED * ECC_SQUARED) / 256.0) * latRad -
            ( 3.0 * ECC_SQUARED / 8.0 + 3.0 * ECC_SQUARED * ECC_SQUARED / 32.0 +
            45.0 * ECC_SQUARED * ECC_SQUARED * ECC_SQUARED / 1024.0) * sin(2.0 * latRad) + (15.0 * ECC_SQUARED * ECC_SQUARED / 256.0 +
            45.0 * ECC_SQUARED * ECC_SQUARED * ECC_SQUARED / 1024.0) * sin(4.0 * latRad) -
            (35.0 * ECC_SQUARED * ECC_SQUARED * ECC_SQUARED / 3072.0) * sin(6.0 * latRad))

      utm_easting = (K0 * n * (a + ((1.0 - t + c) * (a * a * a) / 6.0) +
                    (5.0 - (18.0 * t + t * t) + (72.0 * c) - (58.0 * ECC_PRIME_SQUARED) ) * 
                    (a * a * a * a * a) / 120.0) + EASTING_OFFSET ).round

      utm_northing = (K0 * (m + (n * tan(latRad)) * ( (a * a) / 2.0 + (5.0 - t + (9.0 * c) + (4.0 * c * c) ) * (a * a * a * a) / 24.0 +
                     (61.0 - (58.0 * t + t * t) + 600.0 * c - (330.0 * ECC_PRIME_SQUARED) ) * 
                     (a * a * a * a * a * a) / 720.0))).round

      [utm_zone, utm_easting, utm_northing]
    end



    def ll_to_mgrs(*args)
      ll_to_usng(*args).gsub(/ /,'')
    end

    # /**************************************************************************  
    #   Retrieve the square identification for a given coordinate pair & zone  
    #   See "lettersHelper" function documentation for more details.
    # 
    # ***************************************************************************/

    def find_grid_letters(zone, northing, easting)

      zoneNum  = zone.to_i
      row = 1

      # northing coordinate to single-meter precision
      north_1m = northing.round

      # Get the row position for the square identifier that contains the point
      while (north_1m >= BLOCK_SIZE) do
        north_1m = north_1m - BLOCK_SIZE
        row+=1
      end

      # cycle repeats (wraps) after 20 rows
      row = row % GRIDSQUARE_SET_ROW_SIZE
      col = 0

      # easting coordinate to single-meter precision
      east_1m = easting.round

      # Get the column position for the square identifier that contains the point
      while (east_1m >= BLOCK_SIZE) do
        east_1m = east_1m - BLOCK_SIZE
        col+=1
      end

      # cycle repeats (wraps) after 8 columns
      col = col % GRIDSQUARE_SET_COL_SIZE

      letters_helper(find_set(zoneNum), row, col)
    end

    # /**************************************************************************  
    #     Retrieve the Square Identification (two-character letter code), for the
    #     given row, column and set identifier (set refers to the zone set: 
    #     zones 1-6 have a unique set of square identifiers these identifiers are 
    #     repeated for zones 7-12, etc.) 
    # 
    #     See p. 10 of the "United States National Grid" white paper for a diagram
    #     of the zone sets.
    # 
    # ***************************************************************************/
    def letters_helper(set, row, col)

      # handle case of last row
      if (row == 0)
        row = GRIDSQUARE_SET_ROW_SIZE - 1
      else
        row -= 1
      end
  
      # handle case of last column
      if (col == 0)
        col = GRIDSQUARE_SET_COL_SIZE - 1
      else
        col -= 1  
      end

      case set
        when 1 then
          l1="ABCDEFGH"              # column ids
          l2="ABCDEFGHJKLMNPQRSTUV"  # row ids
        when 2 then 
          l1="JKLMNPQR"
          l2="FGHJKLMNPQRSTUVABCDE"
        when 3 then
          l1="STUVWXYZ"
          l2="ABCDEFGHJKLMNPQRSTUV"
        when 4 then
          l1="ABCDEFGH"
          l2="FGHJKLMNPQRSTUVABCDE"
        when 5 then
          l1="JKLMNPQR"
          l2="ABCDEFGHJKLMNPQRSTUV"
        when 6 then
          l1="STUVWXYZ"
          l2="FGHJKLMNPQRSTUVABCDE"
      end
      "#{l1[col].chr}#{l2[row].chr}"
    end

    # /****************** Find the set for a given zone. ************************
    # 
    #     There are six unique sets, corresponding to individual grid numbers in 
    #     sets 1-6, 7-12, 13-18, etc. Set 1 is the same as sets 7, 13, ..; Set 2 
    #     is the same as sets 8, 14, ..
    # 
    # ***************************************************************************/

    def find_set(zoneNum)
      zoneNum = zoneNum.to_i;
      zoneNum = zoneNum % 6;
      return 6 if zoneNum == 0
      return zoneNum if 1..5===zoneNum
      return -1
    end

    def get_box(mgrs, distance=1)
      mgrs.gsub!(/ /, '')
      gzd, letters, digits = mgrs.match(/(\d{2}\w)(\w{2})(\d+)/).captures
      return nil if (digits.size % 2) != 0
      precision = digits.size / 2
      easting, northing = digits.match(/(\d{#{precision}})(\d{#{precision}})/).captures
      easting = (easting.to_f/1000).to_i
      northing = (northing.to_f/1000).to_i
      boxes = []
      (easting-distance).upto(easting+distance) do |e|
        (northing-distance).upto(northing+distance) do |n|
          boxes << "#{gzd}#{letters}#{e}#{n}"
        end
      end
      boxes
    end
    
    # /**************  convert UTM coords to decimal degrees *********************
    # 
    #     Equations from USGS Bulletin 1532 (or USGS Professional Paper 1395)
    #     East Longitudes are positive, West longitudes are negative. 
    #     North latitudes are positive, South latitudes are negative.
    # 
    #     Expected Input args:
    #       UTMNorthing   : northing-m (numeric), eg. 432001.8  
    #     southern hemisphere NEGATIVE from equator ('real' value - 10,000,000)
    #       UTMEasting    : easting-m  (numeric), eg. 4000000.0
    #       UTMZoneNumber : 6-deg longitudinal zone (numeric), eg. 18
    # 
    #     lat-lon coordinates are turned in the object 'ret' : ret.lat and ret.lon
    # 
    # ***************************************************************************/
    def utm_to_ll(zoneNumber, easting, northing)

      # remove 500,000 meter offset for longitude
      xUTM = easting - EASTING_OFFSET 
      yUTM = northing
      zoneNumber = zoneNumber.to_i

      # origin longitude for the zone (+3 puts origin in zone center) 
      lonOrigin = (zoneNumber - 1) * 6 - 180 + 3 

      # M is the "true distance along the central meridian from the Equator to phi
      # (latitude)
      m = yUTM / K0
      mu = m / ( EQUATORIAL_RADIUS * (1 - (ECC_SQUARED / 4) - 3 * ECC_SQUARED * ECC_SQUARED / 64 -
                (5 * ECC_SQUARED * ECC_SQUARED * ECC_SQUARED / 256) ))

      # phi1 is the "footprint latitude" or the latitude at the central meridian which
      # has the same y coordinate as that of the point (phi (lat), lambda (lon) ).
      phi1Rad = mu + (3 * E1 / 2 - 27 * E1 * E1 * E1 / 32 ) * sin( 2 * mu) +
                     ( 21 * E1 * E1 / 16 - 55 * E1 * E1 * E1 * E1 / 32) * sin( 4 * mu) +
                     (151 * E1 * E1 * E1 / 96) * sin(6 * mu)
      phi1 = phi1Rad * RAD_2_DEG

      # Terms used in the conversion equations
      n1 = EQUATORIAL_RADIUS / sqrt( 1 - (ECC_SQUARED * sin(phi1Rad) * sin(phi1Rad)))
      t1 = tan(phi1Rad) * tan(phi1Rad)
      c1 = ECC_PRIME_SQUARED * cos(phi1Rad) * cos(phi1Rad)
      r1 = EQUATORIAL_RADIUS * (1 - ECC_SQUARED) / ((1 - ECC_SQUARED * sin(phi1Rad) * sin(phi1Rad)) ** 1.5)
      d = xUTM / (n1 * K0)

      # Calculate latitude, in decimal degrees
      lat = phi1Rad - ( n1 * tan(phi1Rad) / r1) * (d * d / 2 - (5 + 3 * t1 + 10 * c1 - 4 * c1 * c1 - 9 * ECC_PRIME_SQUARED) * d * d * d * d / 24 + (61 + 90 * 
              t1 + 298 * c1 + 45 * t1 * t1 - 252 * ECC_PRIME_SQUARED - 3 * c1 * c1) * d * d * d * d * d * d / 720)
      lat = lat * RAD_2_DEG

      # Calculate longitude, in decimal degrees
      lon = (d - (1 + 2 * t1 + c1) * d * d * d / 6 + (5 - 2 * c1 + 28 * t1 - 3 * 
                c1 * c1 + 8 * ECC_PRIME_SQUARED + 24 * t1 * t1) * d * d * d * d * d / 120) /
                cos(phi1Rad)

      lon = lonOrigin + lon * RAD_2_DEG

      [lat, lon]
    end
    
  end
end