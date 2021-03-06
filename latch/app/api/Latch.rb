#Latch Ruby SDK - Set of  reusable classes to  allow developers integrate Latch on their applications.
#Copyright (C) 2013 Eleven Paths
#
#This library is free software; you can redistribute it and/or
#modify it under the terms of the GNU Lesser General Public
#License as published by the Free Software Foundation; either
#version 2.1 of the License, or (at your option) any later version.
#
#This library is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#Lesser General Public License for more details.
#
#You should have received a copy of the GNU Lesser General Public
#License along with this library; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA


require 'base64'
require 'cgi'
require 'openssl'
require 'net/http'
require_relative 'LatchResponse'

class Latch

      attr_accessor  :api_host
	API_HOST = "https://latch.elevenpaths.com"
	API_VERSION = "0.6"
	API_CHECK_STATUS_URL = "/api/0.6/status"
	API_PAIR_URL = "/api/0.6/pair"
	API_PAIR_WITH_ID_URL = "/api/0.6/pairWithId"
	API_UNPAIR_URL =  "/api/0.6/unpair"

	AUTHORIZATION_HEADER_NAME = "Authorization"
	DATE_HEADER_NAME = "X-11Paths-Date"
	AUTHORIZATION_METHOD = "11PATHS"
	AUTHORIZATION_HEADER_FIELD_SEPARATOR = " "

	HMAC_ALGORITHM = "sha1"

	X_11PATHS_HEADER_PREFIX = "X-11Paths-"
	X_11PATHS_HEADER_SEPARATOR = ":"





	# The custom header consists of three parts, the method, the appId and the signature.
	# This method returns the specified part if it exists.
	# @param $part The zero indexed part to be returned
	# @param $header The HTTP header value from which to extract the part
	# @return string the specified part from the header or an empty string if not existent
	def getPartFromHeader(part, header)
		if (header.empty?)
			parts = header.split(AUTHORIZATION_HEADER_FIELD_SEPARATOR)
			if(parts.length > part)
				return parts[part]
			end
		end
		return ""
	end

	# @param $authorizationHeader Authorization HTTP Header
	# @return string the Authorization method. Typical values are "Basic", "Digest" or "11PATHS"
	def getAuthMethodFromHeader(authorizationHeader)
		getPartFromHeader(0, authorizationHeader)
    end

	# @param $authorizationHeader Authorization HTTP Header
	# @return string the requesting application Id. Identifies the application using the API
    def getAppIdFromHeader(authorizationHeader)
    	getPartFromHeader(1, authorizationHeader)
    end


	# @param $authorizationHeader Authorization HTTP Header
	# @return string the signature of the current request. Verifies the identity of the application using the API
    def getSignatureFromHeader(authorizationHeader)
    	getPartFromHeader(2, authorizationHeader)
    end


	# Create an instance of the class with the Application ID and secret obtained from Eleven Paths
	# @param $appId
	# @param $secretKey
    def initialize(appid, secret)
    	@appid = appid
    	@secret = secret
      @api_host = API_HOST
    end


    def http_get(url, headers)
    	     uri = URI.parse(url)
		http = Net::HTTP.new(uri.host, uri.port)

           if (uri.default_port == 443)
		    http.use_ssl = true
		    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
           end


		request = Net::HTTP::Get.new(uri.request_uri)

		headers.map do |key,value|
			request[key] = value
		end

		response = http.request(request)
		response.body
    end


	def http_get_proxy(url)
		LatchResponse.new(http_get(api_host + url, authenticationHeaders('GET', url, nil)))
	end


	def pairWithId(accountId)
		http_get_proxy(API_PAIR_WITH_ID_URL + '/' + accountId)
	end


	def pair(token)
		http_get_proxy(API_PAIR_URL + '/' + token)
	end


	def status(accountId)
		http_get_proxy(API_CHECK_STATUS_URL + '/' + accountId)
	end


	def operationStatus(accountId, operationId)
		http_get_proxy(API_CHECK_STATUS_URL + "/" + accountId + '/' + operationId)
	end


	def unpair(accountId)
		http_get_proxy(API_UNPAIR_URL + '/' + accountId)
	end



	# @param $data the string to sign
	# @return string base64 encoding of the HMAC-SHA1 hash of the data parameter using {@code secretKey} as cipher key.
	def signData(data)
		Base64.encode64(OpenSSL::HMAC.digest(HMAC_ALGORITHM, @secret, data))
	end


	# Calculate the authentication headers to be sent with a request to the API
	# @param $HTTPMethod the HTTP Method, currently only GET is supported
	# @param $queryString the urlencoded string including the path (from the first forward slash) and the parameters
	# @param $xHeaders HTTP headers specific to the 11-paths API. null if not needed.
	# @param $utc the Universal Coordinated Time for the Date HTTP header
	# @return array a map with the Authorization and Date headers needed to sign a Latch API request
	def authenticationHeaders(httpMethod, queryString, xHeaders=nil, utc=nil)
		if (utc == nil)
			utc = getCurrentUTC
		end

		stringToSign = (httpMethod.upcase).strip + "\n" +
						utc.to_s + "\n" +
						getSerializedHeaders(xHeaders) + "\n" +
						queryString.strip

		authorizationHeader = AUTHORIZATION_METHOD +
							   AUTHORIZATION_HEADER_FIELD_SEPARATOR +
							   @appid +
							   AUTHORIZATION_HEADER_FIELD_SEPARATOR +
							   signData(stringToSign).chop

		headers = {}
		headers[AUTHORIZATION_HEADER_NAME] = authorizationHeader
		headers[DATE_HEADER_NAME] = utc
		return headers
	end



	# Prepares and returns a string ready to be signed from the 11-paths specific HTTP headers received
	# @param $xHeaders a non necessarily ordered map of the HTTP headers to be ordered without duplicates.
	# @return a String with the serialized headers, an empty string if no headers are passed, or null if there's a problem
	# such as non 11paths specific headers
	def getSerializedHeaders(xHeaders)
		if(xHeaders != nil)
			headers = xHeaders.inject({}) do |xHeaders, keys|
			  hash[keys[0].downcase] = keys[1]
			  hash
			end


			serializedHeaders = ''

			headers.sort.map do |key,value|
				if(key.downcase == X_11PATHS_HEADER_PREFIX.downcase)
					puts "Error serializing headers. Only specific " + X_11PATHS_HEADER_PREFIX + " headers need to be singed"
					return nil
				end
				serializedHeaders += key + X_11PATHS_HEADER_SEPARATOR + value + ' '
			end
			substitute = 'utf-8'
			return serializedHeaders.gsub(/^[#{substitute}]+|[#{substitute}]+$/, '')
		else
			return ""
		end
	end

	# @return a string representation of the current time in UTC to be used in a Date HTTP Header
	def getCurrentUTC
		Time.now.utc
	end
end
