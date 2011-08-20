require 'spec_helper'
require 'net/http/server/stream'

require 'stringio'

describe Net::HTTP::Server::Stream do
  describe "#read" do
    it "should read data from a socket" do
      data = "foo\0bar"

      stream = described_class.new(StringIO.new(data))
      stream.read.should == data
    end

    it "should read an amount of data from a socket, directly into a buffer" do
      data   = "foo\0bar"
      length = 3
      buffer = ''

      stream = described_class.new(StringIO.new(data))
      stream.read(length,buffer)
      
      buffer.should == data[0,length]
    end
  end

  describe "#each" do
    it "should stop yielding data on 'nil'" do
      results = []

      stream = described_class.new(StringIO.new())
      stream.each { |chunk| results << chunk }

      results.should be_empty
    end

    it "should yield each chunk in the stream" do
      chunks = ['A' * 4096, 'B' * 4096]
      data = chunks.join('')
      results = []

      stream = described_class.new(StringIO.new(data))
      stream.each { |chunk| results << chunk }

      results.should == chunks
    end
  end

  describe "#body" do
    it "should append each chunk to a buffer" do
      chunks = ['A' * 4096, 'B' * 4096]
      data = chunks.join('')

      stream = described_class.new(StringIO.new(data))
      stream.body.should == data
    end
  end

  describe "#write" do
    it "should write to the socket and flush" do
      data = "foo\n\rbar"

      stream = described_class.new(StringIO.new)
      stream.write(data).should == data.length
    end
  end
end
