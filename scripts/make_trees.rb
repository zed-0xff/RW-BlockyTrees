#!/usr/bin/env ruby
require 'zpng'

class TreeMaker
  attr_reader :type, :mc_type

  include ZPNG

  def initialize type
    @type = type
    @mc_type = type
    @mc_type = 'Spruce' if type == 'Pine'
  end

  def stump
    dst = Image.new width: 128, height: 128
    src = Image.new(File.open("../BlockyProps/Textures/Blocky/#{mc_type[0]}/#{mc_type}Log_north.png"))
    dst.copy_from(src, dst_x: 48, dst_y: 90, dst_width: 32, dst_height: 32)
    dst
  end

  def leafless
    @leafless ||=
      begin
        dst = Image.new(open(File.join(File.dirname(__FILE__), "mask.png"), "rb"))

        src = Image.new(File.open("../BlockyProps/Textures/Blocky/#{mc_type[0]}/#{mc_type}Log_north.png"))
        dst.copy_from(src, dst_x: 48, dst_y: 11, dst_width: 32, src_height: 32, dst_height: 16)

        src = Image.new(File.open("../BlockyProps/Textures/Blocky/#{mc_type[0]}/#{mc_type}Wood.png"))
        4.times do |i|
          dst.op_from(src, :*, dst_x: 48, dst_y: 27+32*i, dst_width: 32, dst_height: 32)
        end

        dst
      end
  end

  def leaves
    @leaves ||=
      begin
        src = Image.new(File.open("../BlockyProps/Textures/Blocky/#{mc_type[0]}/#{mc_type}Leaves.png"))
        src.each_pixel do |c,x,y|
          next if c.transparent?
          c.r = c.b = 0 # make them green (orignally grayscale)
          src[x,y] = c
        end

        dst = Image.new(width: 32, height: 48)
        dst.copy_from(src, dst_height: 16, dst_width: 32)
        dst.copy_from(src, dst_y: 16,      dst_width: 32, dst_height: 32)

        mask = Image.new(open(File.join(File.dirname(__FILE__), "mask_leaves.png"), "rb"))
        dst.op_from(mask, :*)

        dst
      end
  end

  def immature
    dst = leafless.dup
    case type
    when 'Acacia'
      dst.copy_from(leaves, dst_x: 32,      dst_y: 8)
      dst.copy_from(leaves, dst_x: 64,      dst_y: 8)
      dst.copy_from(leaves, dst_x: 12,      dst_y: 16)
      dst.copy_from(leaves, dst_x: 84,      dst_y: 16)
      dst.copy_from(leaves, dst_x: 32,      dst_y: 32)
      dst.copy_from(leaves, dst_x: 64,      dst_y: 32)
    when 'Mangrove'
      dst.copy_from(leaves, dst_x: 48,      dst_y: 8)
      5.times { dst.copy_from(leaves, dst_x: 16 + rand(64), dst_y: rand(48)) }
    when 'Spruce'
      # make it smaller
      dst.copy_from(leafless, dst_y: 11, src_height:32, copy_transparent: true)
      dst.copy_from(leafless, dst_y: 22, src_height:32, copy_transparent: true)
      y = 16
      dst.copy_from(leaves, dst_x: 56,      dst_y: y+4, dst_width: 16, src_width: 32, dst_height: 16)
      dst.copy_from(leaves, dst_x: 48,      dst_y: y+4+rand(8))
      dst.copy_from(leaves, dst_x: 48-10,   dst_y: y+8+20+rand(8)-4)
      dst.copy_from(leaves, dst_x: 48+10,   dst_y: y+8+20+rand(8)-4)
      dst.copy_from(leaves, dst_x: 48-20,   dst_y: y+8+40+rand(8)-4, src_height: 16)
      dst.copy_from(leaves, dst_x: 48,      dst_y: y+40+rand(8)-4, src_height: 16)
      dst.copy_from(leaves, dst_x: 48+20,   dst_y: y+8+40+rand(8)-4, src_height: 16)
    else
      step = type == 'Pine' ? 16 : 32
      dst.copy_from(leaves, dst_x: 48,      dst_y: 4+rand(12))
      dst.copy_from(leaves, dst_x: 48-step, dst_y: step-4+rand(12))
      dst.copy_from(leaves, dst_x: 48+step, dst_y: step-4+rand(12))
      if type == 'Jungle'
        dst.copy_from(leaves, dst_x: 48,    dst_y: step)
      else
        dst.copy_from(leaves, dst_x: 48,    dst_y: step*(1.2+rand/5)+rand(8)-4)
      end
    end
    dst
  end

  def mature
    w = 32
    dst = immature.dup
    case type
    when 'Acacia'
      dst = leafless.dup
      dst.copy_from(leaves, dst_x: 40,      dst_y: 0)
      dst.copy_from(leaves, dst_x: 56,      dst_y: 0)
      8.times{ |i| dst.copy_from(leaves, dst_x: i*w/2, dst_y: 12) }
      dst.copy_from(leaves, dst_x: 32,      dst_y: 18)
      dst.copy_from(leaves, dst_x: 64,      dst_y: 18)
    when 'Pine'
      # nop
    when 'Jungle'
      dst.copy_from(leaves, dst_x: 32,   dst_y: 16)
      dst.copy_from(leaves, dst_x: 32+w, dst_y: 16)
      dst.copy_from(leaves, dst_x:  0,   dst_y: 24)
      dst.copy_from(leaves, dst_x: 96,   dst_y: 24)
    when 'Mangrove'
      5.times { dst.copy_from(leaves, dst_x: 8 + rand(96), dst_y: rand(64)) }
    when 'Spruce'
      3.times{ |i| dst.copy_from(leaves, dst_x: 16+w*i,   dst_y: 48+rand(8)-4) }
      4.times{ |i| dst.copy_from(leaves, dst_x:  0+w*i,   dst_y: 64+rand(8)-4, src_height: 16+rand(8)) }
    else
      2.times { |i| dst.copy_from(leaves, dst_x: 32+w*i, dst_y: rand(4)) }
      3.times { |i| dst.copy_from(leaves, dst_x: 16+w*i, dst_y: 12+rand(8)) }

      y = 22 + rand(9)
      4.times { |i| dst.copy_from(leaves, dst_x:    w*i, dst_y: y+rand(4)) }
    end
    dst
  end

  def make!
#    stump.save("#{@type}_Stump.png")
#    leafless.save("#{@type}_Leafless.png")
    4.times do |i|
      fname = "#{@type}_Immature#{('A'.ord+i).chr}.png"
      immature.save(fname)
      puts "[.] #{fname}"
    end
    4.times do |i|
      fname = "#{@type}#{('A'.ord+i).chr}.png"
      mature.save(fname)
      puts "[.] #{fname}"
    end
  end
end

if ARGV.any?
  ARGV.each do |type|
    TreeMaker.new(type).make!
  end
  exit
end

Dir["../BlockyProps/Textures/Blocky/?/*Log_north.png"].each do |fname|
  type = File.basename(fname).sub("Log_north.png", "")
  puts "[*] #{type}"
  TreeMaker.new(type).make!
end
